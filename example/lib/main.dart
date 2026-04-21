import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:keyboard_size_peek/keyboard_size_peek.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _focusNode = FocusNode();
  final _log = <String>[];
  StreamSubscription<KeyboardSizeEvent>? _sub;

  double _peekHeight = 0;
  int _lastDurationMs = 0;
  bool _panelOpen = false;

  @override
  void initState() {
    super.initState();
    _sub = KeyboardSizePeek.events.listen((event) {
      setState(() {
        _peekHeight = event.height;
        _lastDurationMs = event.durationMs;
        final verb = event.isShowing ? 'willShow' : 'willHide';
        final stamp = DateTime.now().toIso8601String().substring(11, 23);
        _log.insert(
          0,
          '[$stamp] $verb  h=${event.height.toStringAsFixed(1)}  d=${event.durationMs}ms',
        );
        if (_log.length > 20) _log.removeLast();
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _HomePage(
        focusNode: _focusNode,
        peekHeight: _peekHeight,
        lastDurationMs: _lastDurationMs,
        panelOpen: _panelOpen,
        onTogglePanel: () {
          setState(() => _panelOpen = !_panelOpen);
          if (_panelOpen) _focusNode.unfocus();
        },
        onHideKeyboard: () => _focusNode.unfocus(),
        log: _log,
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  final FocusNode focusNode;
  final double peekHeight;
  final int lastDurationMs;
  final bool panelOpen;
  final VoidCallback onTogglePanel;
  final VoidCallback onHideKeyboard;
  final List<String> log;

  const _HomePage({
    required this.focusNode,
    required this.peekHeight,
    required this.lastDurationMs,
    required this.panelOpen,
    required this.onTogglePanel,
    required this.onHideKeyboard,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    // Live inset — animates every frame while the keyboard slides.
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    // The star of the show. During SHOW: peekHeight jumps to the final value
    // the moment the OS decides to show the keyboard, so floorHeight jumps too
    // and the text field pops up instantly — the keyboard then slides up
    // underneath. During HIDE: peekHeight drops to 0 immediately, but
    // viewInsets keeps animating down, so max() keeps the floor tracking the
    // keyboard all the way to the bottom.
    final bool anyActive = panelOpen || viewInsets > 0 || peekHeight > 0;
    final double floorHeight =
        anyActive ? math.max(peekHeight, viewInsets) : safeBottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('keyboard_size_peek demo')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatsCard(
                    peekHeight: peekHeight,
                    viewInsets: viewInsets,
                    lastDurationMs: lastDurationMs,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: onHideKeyboard,
                          child: const Text('Hide keyboard'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: onTogglePanel,
                          child: Text(panelOpen ? 'Close panel' : 'Open panel'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Event log',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: log.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          log[i],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Text field pinned directly above the floor — this is the visual
          // test. Tap it: if the plugin works, the field + orange bar pop up
          // instantly to rest on top of the keyboard as it slides in.
          Container(
            color: Colors.orange.shade100,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Tap to show keyboard',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.send),
              ],
            ),
          ),
          // The "floor" — keyboard and custom panel share this slot.
          ClipRect(
            child: AnimatedContainer(
              duration: viewInsets > 0
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              height: floorHeight,
              color: panelOpen
                  ? Colors.deepPurple.shade100
                  : Colors.transparent,
              child: panelOpen
                  ? const Center(
                      child: Text(
                        'Custom panel at keyboard height',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final double peekHeight;
  final double viewInsets;
  final int lastDurationMs;

  const _StatsCard({
    required this.peekHeight,
    required this.viewInsets,
    required this.lastDurationMs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Row(
              label: 'peek height (final, pre-animation)',
              value: '${peekHeight.toStringAsFixed(1)} px',
              highlight: true,
            ),
            _Row(
              label: 'MediaQuery.viewInsets.bottom (live)',
              value: '${viewInsets.toStringAsFixed(1)} px',
            ),
            _Row(
              label: 'animation duration',
              value: '$lastDurationMs ms',
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _Row({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).textTheme.bodyMedium?.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: color))),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

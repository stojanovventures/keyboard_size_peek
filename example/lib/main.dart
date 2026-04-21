import 'dart:async';

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
  final _log = <String>[];
  StreamSubscription<KeyboardSizeEvent>? _sub;
  double _lastHeight = 0;
  int _lastDurationMs = 0;

  @override
  void initState() {
    super.initState();
    _sub = KeyboardSizePeek.events.listen((event) {
      setState(() {
        _lastHeight = event.height;
        _lastDurationMs = event.durationMs;
        final verb = event.isShowing ? 'willShow' : 'willHide';
        final stamp = DateTime.now().toIso8601String().substring(11, 23);
        _log.insert(
          0,
          '[$stamp] $verb  height=${event.height.toStringAsFixed(1)}  duration=${event.durationMs}ms',
        );
        if (_log.length > 20) _log.removeLast();
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('keyboard_size_peek')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last event',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('height: ${_lastHeight.toStringAsFixed(1)} logical px'),
                      Text('duration: $_lastDurationMs ms'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Focus to show keyboard',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Event log',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _log.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _log[i],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

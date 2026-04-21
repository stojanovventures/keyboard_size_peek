/// Reports the final height of the on-screen keyboard the moment the OS
/// decides to show or hide it — before the animation starts.
///
/// Use [KeyboardSizePeek.events] as a broadcast stream of [KeyboardSizeEvent]s.
library;

import 'dart:async';

import 'package:flutter/services.dart';

/// A single show/hide event from the system keyboard.
class KeyboardSizeEvent {
  /// Final keyboard height in logical pixels.
  ///
  /// Non-zero while the keyboard is about to become visible, `0` while it is
  /// about to hide. This is the resting height — not an intermediate value
  /// during the animation.
  final double height;

  /// Reported animation duration in milliseconds, as provided by the
  /// platform. Use this to match your own transitions to the system
  /// keyboard animation.
  final int durationMs;

  /// Creates an event. Consumers normally receive these from the stream
  /// rather than constructing them directly.
  const KeyboardSizeEvent({required this.height, required this.durationMs});

  /// `true` when the event represents the keyboard about to appear
  /// ([height] greater than `0`).
  bool get isShowing => height > 0;

  /// `true` when the event represents the keyboard about to disappear
  /// ([height] equal to `0`).
  bool get isHiding => height == 0;

  @override
  String toString() =>
      'KeyboardSizeEvent(height: $height, durationMs: $durationMs)';
}

/// Entry point for listening to keyboard show/hide events.
///
/// iOS — fires on `keyboardWillShowNotification` /
/// `keyboardWillHideNotification` with `UIKeyboardFrameEndUserInfoKey`.
///
/// Android 11+ — fires on `WindowInsetsAnimationCompat.Callback.onStart`
/// with `bounds.upperBound`. Earlier Android versions are best-effort via
/// the AndroidX compat layer; if you need exact values, fall back to
/// `MediaQuery.viewInsets.bottom` on those devices.
///
/// Example:
/// ```dart
/// final sub = KeyboardSizePeek.events.listen((event) {
///   if (event.isShowing) {
///     setState(() => _panelHeight = event.height);
///   }
/// });
/// ```
class KeyboardSizePeek {
  static const _channel = EventChannel('keyboard_size_peek/events');

  static Stream<KeyboardSizeEvent>? _stream;

  /// Broadcast stream of [KeyboardSizeEvent]s. Subscribe once and reuse —
  /// multiple listeners are supported and share the same underlying channel
  /// subscription.
  static Stream<KeyboardSizeEvent> get events {
    return _stream ??= _channel.receiveBroadcastStream().map((dynamic e) {
      final map = Map<String, dynamic>.from(e as Map);
      return KeyboardSizeEvent(
        height: (map['height'] as num).toDouble(),
        durationMs: (map['durationMs'] as num).toInt(),
      );
    });
  }
}

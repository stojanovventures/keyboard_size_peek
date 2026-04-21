import 'dart:async';

import 'package:flutter/services.dart';

class KeyboardSizeEvent {
  /// Final keyboard height in logical pixels. `0` when the keyboard is
  /// about to hide.
  final double height;

  /// Reported animation duration in milliseconds. Use this to match your
  /// own transitions to the system keyboard animation.
  final int durationMs;

  const KeyboardSizeEvent({required this.height, required this.durationMs});

  bool get isShowing => height > 0;
  bool get isHiding => height == 0;

  @override
  String toString() =>
      'KeyboardSizeEvent(height: $height, durationMs: $durationMs)';
}

/// Emits keyboard size events the moment the OS decides to show or hide the
/// keyboard — before the animation starts.
///
/// iOS: fires on `keyboardWillShowNotification` / `keyboardWillHideNotification`
/// with `UIKeyboardFrameEndUserInfoKey`.
///
/// Android 11+: fires on `WindowInsetsAnimationCompat.Callback.onStart` with
/// `bounds.upperBound`. Earlier Android versions are best-effort via the
/// AndroidX compat layer; if you need exact values, fall back to
/// `MediaQuery.viewInsets.bottom` on those devices.
class KeyboardSizePeek {
  static const _channel = EventChannel('keyboard_size_peek/events');

  static Stream<KeyboardSizeEvent>? _stream;

  /// Broadcast stream of [KeyboardSizeEvent]s. Subscribe once and reuse.
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

# keyboard_size_peek

Reports the keyboard's final height **before** the show/hide animation starts. Size bottom sheets and attachment panels without the usual debounce-and-settle workaround.

## Why

`MediaQuery.viewInsets.bottom` only reflects the keyboard's *current* animating inset — every frame while it slides in. If you need to lay out a custom panel at the resting keyboard height, you have two options: wait for the animation to settle (visible delay), or hard-code a magic number that's wrong on some devices or keyboard types.

Both iOS and Android's native APIs already publish the resting height the moment the keyboard is requested, before any pixels move:

- **iOS** — `keyboardWillShowNotification` fires with `UIKeyboardFrameEndUserInfoKey`
- **Android 11+** — `WindowInsetsAnimationCompat.Callback.onStart` provides `bounds.upperBound`

This plugin pipes that value through to Dart as a broadcast stream.

## Platform support

| Platform   | Support |
| ---------- | ------- |
| iOS 13+    | Full — fires on `keyboardWillShow` / `keyboardWillHide` |
| Android 11+ (API 30) | Full — native `WindowInsetsAnimation` |
| Android 7–10 (API 24–29) | Best-effort via the AndroidX compat layer |
| Web / macOS / Windows / Linux | No events — fall back to `MediaQuery.viewInsets.bottom` |

## Usage

```dart
import 'package:keyboard_size_peek/keyboard_size_peek.dart';

StreamSubscription<KeyboardSizeEvent>? _sub;

@override
void initState() {
  super.initState();
  _sub = KeyboardSizePeek.events.listen((event) {
    if (event.isShowing) {
      // event.height is the final keyboard height in logical px
      // event.durationMs is the system animation duration
      setState(() => _panelHeight = event.height);
    }
  });
}

@override
void dispose() {
  _sub?.cancel();
  super.dispose();
}
```

### Real-world example: sizing an attachment panel

If you swap the keyboard for a custom panel (emoji picker, attachment grid, etc.), you want the panel to open at exactly the keyboard's height so the composer doesn't jump. Subscribe to the stream and persist the value:

```dart
KeyboardSizePeek.events.listen((event) {
  if (event.isShowing) {
    _panelHeight = event.height;
    _prefs.setLastKeyboardHeight(event.height);
  }
});
```

No debounce timer. No magic number. First-ever open is instant.

## API

```dart
class KeyboardSizeEvent {
  /// Final keyboard height in logical pixels. 0 when hiding.
  final double height;

  /// System animation duration in milliseconds.
  final int durationMs;

  bool get isShowing; // height > 0
  bool get isHiding;  // height == 0
}

class KeyboardSizePeek {
  /// Broadcast stream of events. Subscribe once and reuse.
  static Stream<KeyboardSizeEvent> get events;
}
```

## Notes

- The stream is a broadcast stream — multiple listeners are fine.
- On iOS, `keyboardWillShow` also fires when the keyboard resizes (standard → emoji, split → full, etc.). You'll get a fresh `height` every time.
- On Android, events fire once per animation — show, hide, and type-switch all produce an event.
- Heights are logical pixels (iOS points, Android dp). They match Flutter's logical pixel coordinate system directly — no conversion needed.

## License

MIT

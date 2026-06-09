## 0.1.2

- Return an inert empty stream on platforms without a native implementation (macOS/desktop/web) instead of throwing `MissingPluginException` when listening.

## 0.1.1

- Add Swift Package Manager support for iOS (alongside CocoaPods).
- Add `topics` to pubspec for discoverability.
- Expand dartdoc coverage on all public API members.

## 0.1.0

- Initial release.
- iOS: emits events from `UIResponder.keyboardWillShowNotification` / `keyboardWillHideNotification` using `UIKeyboardFrameEndUserInfoKey`.
- Android: emits events from `WindowInsetsAnimationCompat.Callback.onStart` using `bounds.upperBound`.
- Broadcast `Stream<KeyboardSizeEvent>` with `height` (logical px) and `durationMs`.

## 0.1.0

- Initial release.
- iOS: emits events from `UIResponder.keyboardWillShowNotification` / `keyboardWillHideNotification` using `UIKeyboardFrameEndUserInfoKey`.
- Android: emits events from `WindowInsetsAnimationCompat.Callback.onStart` using `bounds.upperBound`.
- Broadcast `Stream<KeyboardSizeEvent>` with `height` (logical px) and `durationMs`.

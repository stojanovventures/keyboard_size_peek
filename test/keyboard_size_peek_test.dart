import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_size_peek/keyboard_size_peek.dart';

void main() {
  group('KeyboardSizeEvent', () {
    test('isShowing is true for non-zero height', () {
      const e = KeyboardSizeEvent(height: 335, durationMs: 250);
      expect(e.isShowing, true);
      expect(e.isHiding, false);
    });

    test('isHiding is true for zero height', () {
      const e = KeyboardSizeEvent(height: 0, durationMs: 250);
      expect(e.isHiding, true);
      expect(e.isShowing, false);
    });
  });
}

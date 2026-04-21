import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:keyboard_size_peek/keyboard_size_peek.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('events stream is exposed', (WidgetTester tester) async {
    // We can't trigger a real keyboard from a widget test, so we only
    // verify the stream is constructed without throwing.
    final stream = KeyboardSizePeek.events;
    expect(stream, isNotNull);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dorado_challenge/main.dart' show DoradoApp;

void main() {
  testWidgets('ExchangePage renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: DoradoApp()));
    expect(find.text('Currency Exchange'), findsOneWidget);
  });
}

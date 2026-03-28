import 'package:flutter_test/flutter_test.dart';
import 'package:party_chaos/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PartyChaosApp());
    expect(find.text('Welcome to Party Games!'), findsOneWidget);
  });
}

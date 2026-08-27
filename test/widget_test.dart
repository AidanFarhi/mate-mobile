import 'package:flutter_test/flutter_test.dart';
import 'package:mate/app/app.dart';

void main() {
  testWidgets('app boots to the placeholder home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MateApp());

    expect(find.text('Mate'), findsOneWidget);
    expect(find.text('Chess with your friends.'), findsOneWidget);
  });
}

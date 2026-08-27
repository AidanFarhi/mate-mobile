import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_and_light/app/app.dart';

void main() {
  testWidgets('app boots to the placeholder home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ShadowAndLightApp());

    expect(find.text('Shadow & Light'), findsOneWidget);
    expect(find.text('Chess with your friends.'), findsOneWidget);
  });
}

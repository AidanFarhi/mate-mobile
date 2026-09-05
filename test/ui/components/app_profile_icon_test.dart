import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/ui/components/app_profile_icon.dart';

import '../../support/pump_theme.dart';

void main() {
  test('the icon set is fixed and every id in it is valid', () {
    expect(AppProfileIcons.count, 8);
    expect(AppProfileIcons.glyphs.toSet(), hasLength(AppProfileIcons.count));
    for (int id = 0; id < AppProfileIcons.count; id++) {
      expect(AppProfileIcons.isValid(id), isTrue);
    }
    expect(AppProfileIcons.isValid(-1), isFalse);
    expect(AppProfileIcons.isValid(AppProfileIcons.count), isFalse);
  });

  testWidgets('every id renders its own glyph', (WidgetTester tester) async {
    for (int id = 0; id < AppProfileIcons.count; id++) {
      await pumpThemed(tester, AppProfileIcon(iconId: id));
      expect(find.text(AppProfileIcons.glyphs[id]), findsOneWidget);
    }
  });

  testWidgets('inverted is the signed-in user; plain is everyone else', (
    WidgetTester tester,
  ) async {
    await pumpThemed(tester, const AppProfileIcon(iconId: 0));
    BoxDecoration decoration =
        tester.widget<Container>(find.byType(Container)).decoration!
            as BoxDecoration;
    expect(decoration.color, AppPalette.dark.avatarFill);

    await pumpThemed(tester, const AppProfileIcon(iconId: 0, inverted: true));
    decoration =
        tester.widget<Container>(find.byType(Container)).decoration!
            as BoxDecoration;
    expect(decoration.color, AppPalette.dark.textPrimary);
  });

  testWidgets('the avatar keeps its size at 200% text', (
    WidgetTester tester,
  ) async {
    // Avatars stand in for artwork. If the glyph scaled with the text setting
    // it would burst the circle and reflow every row it sits in.
    await pumpThemed(
      tester,
      const AppProfileIcon(iconId: 0, size: 34),
      textScaler: const TextScaler.linear(2),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AppProfileIcon)), const Size(34, 34));
  });
}

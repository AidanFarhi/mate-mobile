import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/app/theme/app_theme.dart';
import 'package:mate/app/theme/app_typography.dart';
import 'package:mate/app/theme/board_palette.dart';

void main() {
  test('the theme is dark and there is only one', () {
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
  });

  test('all three extensions are attached', () {
    expect(AppTheme.dark.extension<AppPalette>(), same(AppPalette.dark));
    expect(AppTheme.dark.extension<AppTypography>(), isNotNull);
    expect(
      AppTheme.dark.extension<BoardPalette>(),
      same(BoardPalette.standard),
    );
  });

  test('the ColorScheme is built from the palette, not Material defaults', () {
    final ColorScheme scheme = AppTheme.dark.colorScheme;
    expect(scheme.primary, AppPalette.dark.accent);
    expect(scheme.onPrimary, AppPalette.dark.onAccent);
    expect(scheme.surface, AppPalette.dark.ground);
    expect(scheme.onSurface, AppPalette.dark.textPrimary);
    expect(scheme.error, AppPalette.dark.danger);
    expect(AppTheme.dark.scaffoldBackgroundColor, AppPalette.dark.ground);
  });

  test('every Material text slot uses a bundled family', () {
    final TextTheme text = AppTheme.dark.textTheme;
    final List<TextStyle?> styles = <TextStyle?>[
      text.headlineLarge,
      text.headlineMedium,
      text.headlineSmall,
      text.titleLarge,
      text.titleMedium,
      text.titleSmall,
      text.bodyLarge,
      text.bodyMedium,
      text.bodySmall,
      text.labelLarge,
      text.labelMedium,
      text.labelSmall,
    ];
    for (final TextStyle? style in styles) {
      expect(
        style?.fontFamily,
        anyOf(AppTypography.sansFamily, AppTypography.monoFamily),
        reason: 'a slot fell back to the platform default face',
      );
    }
  });

  test('every type role carries a matching fontVariation', () {
    // Both faces are variable. A style with a weight but no `wght` variation
    // renders at whatever the platform decides, which is the bug this catches.
    final AppTypography type = AppTypography.standard;
    final List<TextStyle> roles = <TextStyle>[
      type.wordmark,
      type.wordmarkSubhead,
      type.screenTitle,
      type.sectionTitle,
      type.statValue,
      type.body,
      type.rowPrimary,
      type.rowPrimaryCompact,
      type.rowSecondary,
      type.button,
      type.buttonSmall,
      type.tabLabel,
      type.label,
      type.labelWide,
      type.meta,
      type.metaSmall,
      type.notation,
      type.code,
    ];
    for (final TextStyle style in roles) {
      final List<FontVariation> variations =
          style.fontVariations ?? <FontVariation>[];
      expect(variations, hasLength(1));
      expect(variations.single.axis, 'wght');
      expect(variations.single.value, style.fontWeight!.value.toDouble());
    }
  });

  testWidgets('extensions resolve through BuildContext', (
    WidgetTester tester,
  ) async {
    late AppPalette palette;
    late AppTypography type;
    late BoardPalette board;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (BuildContext context) {
            palette = AppPalette.of(context);
            type = AppTypography.of(context);
            board = BoardPalette.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(palette.accent, const Color(0xFFB4C4A8));
    expect(type.screenTitle.fontSize, 22);
    expect(board.lightSquare, const Color(0xFFD9DED0));
  });
}

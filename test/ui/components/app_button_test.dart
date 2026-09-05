import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/ui/components/app_button.dart';

import '../../support/pump_theme.dart';

ButtonStyle _styleOf(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton)).style!;

Color _background(ButtonStyle style, Set<WidgetState> states) =>
    style.backgroundColor!.resolve(states)!;

Color _foreground(ButtonStyle style, Set<WidgetState> states) =>
    style.foregroundColor!.resolve(states)!;

void main() {
  testWidgets('each variant has its own enabled fill', (
    WidgetTester tester,
  ) async {
    final Set<Color> fills = <Color>{};
    for (final AppButtonVariant variant in AppButtonVariant.values) {
      await pumpThemed(
        tester,
        AppButton(label: 'Go', onPressed: () {}, variant: variant),
      );
      fills.add(_background(_styleOf(tester), const <WidgetState>{}));
    }
    expect(fills, hasLength(AppButtonVariant.values.length));
  });

  testWidgets('every variant shares one disabled treatment', (
    WidgetTester tester,
  ) async {
    // A disabled destructive button that still looks dangerous reads as
    // "about to happen" rather than "not available", so the variant's own
    // colors have to drop away entirely when it is off.
    for (final AppButtonVariant variant in AppButtonVariant.values) {
      await pumpThemed(
        tester,
        AppButton(label: 'Go', onPressed: null, variant: variant),
      );
      final ButtonStyle style = _styleOf(tester);
      const Set<WidgetState> disabled = <WidgetState>{WidgetState.disabled};
      expect(_background(style, disabled), AppPalette.dark.fill);
      expect(_foreground(style, disabled), AppPalette.dark.textTertiary);
    }
  });

  testWidgets('a null callback disables the underlying button', (
    WidgetTester tester,
  ) async {
    await pumpThemed(
      tester,
      const AppButton(label: 'Continue', onPressed: null),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isFalse,
    );
  });

  testWidgets('tapping fires the callback', (WidgetTester tester) async {
    int taps = 0;
    await pumpThemed(
      tester,
      AppButton(label: 'Continue', onPressed: () => taps++),
    );
    await tester.tap(find.byType(AppButton));
    expect(taps, 1);
  });

  testWidgets('sizes set a floor, and the label never clips', (
    WidgetTester tester,
  ) async {
    // The design's heights are minimums, not fixed sizes. At 200% text a 16px
    // label is 32px tall and a 52px CTA has 20px of padding to give -- so the
    // button has to be free to grow, or it clips its own copy.
    const Map<AppButtonSize, double> minHeights = <AppButtonSize, double>{
      AppButtonSize.large: 52,
      AppButtonSize.medium: 48,
      AppButtonSize.small: 42,
    };

    for (final MapEntry<AppButtonSize, double> entry in minHeights.entries) {
      for (final double scale in <double>[1, 1.5, 2, 3]) {
        await pumpThemed(
          tester,
          AppButton(label: 'Continue', onPressed: () {}, size: entry.key),
          textScaler: TextScaler.linear(scale),
        );
        expect(tester.takeException(), isNull);

        final double height = tester.getSize(find.byType(AppButton)).height;
        final double labelHeight = tester.getSize(find.text('Continue')).height;

        expect(
          height,
          greaterThanOrEqualTo(entry.value),
          reason: '${entry.key} fell below its design height at $scale',
        );
        expect(
          height,
          greaterThanOrEqualTo(labelHeight),
          reason: '${entry.key} clipped its label at $scale',
        );
      }
    }
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/ui/components/app_result_chip.dart';

import '../../support/pump_theme.dart';

BoxDecoration _decorationOf(WidgetTester tester) =>
    tester.widget<Container>(find.byType(Container)).decoration!
        as BoxDecoration;

void main() {
  testWidgets('every kind renders with its own semantic label', (
    WidgetTester tester,
  ) async {
    // Screen readers must not be handed a bare "W". Iterating the enum means a
    // fifth result state cannot be added without either a label or a failure.
    final Set<String> labels = <String>{};
    for (final ResultChipKind kind in ResultChipKind.values) {
      await pumpThemed(tester, AppResultChip(kind: kind));
      final Semantics node = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.byType(Container),
              matching: find.byType(Semantics),
            )
            .first,
      );
      final String? label = node.properties.label;
      expect(label, isNotNull);
      labels.add(label!);
    }
    expect(labels, hasLength(ResultChipKind.values.length));
  });

  testWidgets('win, loss and draw are filled; unfinished is outlined', (
    WidgetTester tester,
  ) async {
    // The four states have to be told apart at a glance in a history list, and
    // "no result recorded" is the one that is not an outcome -- so it is the
    // one without a fill.
    for (final ResultChipKind kind in ResultChipKind.values) {
      await pumpThemed(tester, AppResultChip(kind: kind));
      final BoxDecoration decoration = _decorationOf(tester);
      if (kind == ResultChipKind.unfinished) {
        expect(decoration.color, Colors.transparent);
        expect(decoration.border, isNotNull);
      } else {
        expect(decoration.color, isNot(Colors.transparent));
        expect(decoration.border, isNull);
      }
    }
  });

  testWidgets('win reads accent and loss reads danger', (
    WidgetTester tester,
  ) async {
    await pumpThemed(tester, const AppResultChip(kind: ResultChipKind.win));
    expect(_decorationOf(tester).color, AppPalette.dark.accentWashStrong);

    await pumpThemed(tester, const AppResultChip(kind: ResultChipKind.loss));
    expect(_decorationOf(tester).color, AppPalette.dark.dangerWash);
  });

  testWidgets('the chip grows rather than clipping at 200% text', (
    WidgetTester tester,
  ) async {
    await pumpThemed(
      tester,
      const AppResultChip(kind: ResultChipKind.win),
      textScaler: const TextScaler.linear(2),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(AppResultChip)).height,
      greaterThanOrEqualTo(26),
    );
  });
}

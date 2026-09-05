import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/ui/components/app_tab_bar.dart';

import '../../support/pump_theme.dart';

const List<AppTabItem> _items = <AppTabItem>[
  AppTabItem(label: 'Play', route: '/'),
  AppTabItem(label: 'Friends', route: '/friends'),
  AppTabItem(label: 'You', route: '/you'),
];

Color _labelColor(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!.color!;

void main() {
  testWidgets('exactly one label reads as active', (WidgetTester tester) async {
    for (int selected = 0; selected < _items.length; selected++) {
      await pumpThemed(
        tester,
        AppTabBar(items: _items, selectedIndex: selected, onSelected: (_) {}),
      );
      for (int i = 0; i < _items.length; i++) {
        expect(
          _labelColor(tester, _items[i].label),
          i == selected
              ? AppPalette.dark.textPrimary
              : AppPalette.dark.textSecondary,
        );
      }
    }
  });

  testWidgets('tapping a tab reports its index', (WidgetTester tester) async {
    final List<int> taps = <int>[];
    await pumpThemed(
      tester,
      AppTabBar(items: _items, selectedIndex: 0, onSelected: taps.add),
    );
    await tester.tap(find.text('Friends'));
    await tester.tap(find.text('You'));
    expect(taps, <int>[1, 2]);
  });

  testWidgets('the dot holds its slot on every tab', (
    WidgetTester tester,
  ) async {
    // The inactive dot is transparent rather than absent. If it were removed,
    // switching tabs would move every label in the bar.
    await pumpThemed(
      tester,
      AppTabBar(items: _items, selectedIndex: 0, onSelected: (_) {}),
    );
    final double first = tester.getTopLeft(find.text('Play')).dy;
    final double second = tester.getTopLeft(find.text('Friends')).dy;
    expect(first, second);
    expect(
      find.descendant(
        of: find.byType(AppTabBar),
        matching: find.byType(Container),
      ),
      findsNWidgets(_items.length),
    );
  });
}

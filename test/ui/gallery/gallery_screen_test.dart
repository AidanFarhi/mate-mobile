import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/app/theme/app_theme.dart';
import 'package:mate/ui/components/app_button.dart';
import 'package:mate/ui/components/app_empty_state.dart';
import 'package:mate/ui/components/app_error_state.dart';
import 'package:mate/ui/components/app_loading.dart';
import 'package:mate/ui/components/app_profile_icon.dart';
import 'package:mate/ui/components/app_result_chip.dart';
import 'package:mate/ui/components/app_screen_header.dart';
import 'package:mate/ui/components/app_tab_bar.dart';
import 'package:mate/ui/gallery/gallery_screen.dart';

/// Every shared component the gallery is required to show.
final Map<String, Finder> _components = <String, Finder>{
  'AppButton': find.byType(AppButton),
  'AppEmptyState': find.byType(AppEmptyState),
  'AppErrorState': find.byType(AppErrorState),
  'AppLoadingIndicator': find.byType(AppLoadingIndicator),
  'AppLoadingScreen': find.byType(AppLoadingScreen),
  'AppProfileIcon': find.byType(AppProfileIcon),
  'AppResultChip': find.byType(AppResultChip),
  'AppSectionLabel': find.byType(AppSectionLabel),
  'AppTabBar': find.byType(AppTabBar),
};

/// What one end-to-end scroll of the gallery turned up.
typedef GallerySweep = ({Set<String> components, Set<String> texts});

Future<void> pumpGallery(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.dark, home: const GalleryScreen()),
  );
  await tester.pump();
}

/// Scrolls the gallery end to end, returning everything seen on the way.
///
/// The list is lazy, so nothing below the fold exists until it is scrolled to.
/// That makes one pass serve both jobs: an overflow anywhere on the page throws
/// during layout and fails immediately, and whatever never appears at all is
/// missing from the gallery.
Future<GallerySweep> scrollThrough(WidgetTester tester) async {
  final Set<String> components = <String>{};
  final Set<String> texts = <String>{};
  final Finder list = find.byType(ListView);

  for (int step = 0; step < 60; step++) {
    expect(tester.takeException(), isNull, reason: 'layout error, step $step');

    for (final MapEntry<String, Finder> entry in _components.entries) {
      if (entry.value.evaluate().isNotEmpty) {
        components.add(entry.key);
      }
    }
    for (final Element element in find.byType(Text).evaluate()) {
      final String? data = (element.widget as Text).data;
      if (data != null) {
        texts.add(data);
      }
    }

    final ScrollableState state = tester.state<ScrollableState>(
      find.descendant(of: list, matching: find.byType(Scrollable)),
    );
    if (state.position.pixels >= state.position.maxScrollExtent) {
      break;
    }
    await tester.drag(list, const Offset(0, -300));
    // Not pumpAndSettle: AppLoadingScreen spins forever and would time out.
    await tester.pump(const Duration(milliseconds: 100));
  }

  expect(tester.takeException(), isNull);
  return (components: components, texts: texts);
}

void main() {
  testWidgets('the gallery shows every shared component', (
    WidgetTester tester,
  ) async {
    await pumpGallery(tester);
    final GallerySweep sweep = await scrollThrough(tester);
    expect(sweep.components, _components.keys.toSet());
  });

  testWidgets('the gallery shows every profile icon and result state', (
    WidgetTester tester,
  ) async {
    // The two families with a fixed membership. A ninth icon or a fifth result
    // state that nobody added to the gallery fails here.
    await pumpGallery(tester);
    final GallerySweep sweep = await scrollThrough(tester);
    expect(sweep.texts, containsAll(AppProfileIcons.glyphs));
    expect(
      sweep.texts,
      containsAll(ResultChipKind.values.map((ResultChipKind k) => k.name)),
    );
  });

  testWidgets('every section lays out at 100% text', (
    WidgetTester tester,
  ) async {
    await pumpGallery(tester);
    await scrollThrough(tester);
  });

  testWidgets('every section lays out at 200% text', (
    WidgetTester tester,
  ) async {
    // #3 asks for layouts to be verified at 200%. Doing it here rather than by
    // eye is what makes a component that cannot take the scaling break CI.
    await pumpGallery(tester);
    final double before = tester.getSize(find.text('BUTTONS')).height;

    await tester.tap(find.text('200%'));
    await tester.pump();
    expect(
      tester.getSize(find.text('BUTTONS')).height,
      greaterThan(before),
      reason: 'the scale control did not scale the specimens',
    );

    await scrollThrough(tester);
  });
}

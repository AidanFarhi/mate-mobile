import 'package:flutter/material.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/app/theme/app_spacing.dart';
import 'package:mate/app/theme/app_typography.dart';

/// One destination in [AppTabBar].
@immutable
class AppTabItem {
  const AppTabItem({required this.label, required this.route});

  final String label;

  /// The `RoutePaths` location this tab selects.
  final String route;
}

/// The bottom tab bar: three labels, and a dot under the active one.
///
/// Not a [NavigationBar]. The design has no icons at all -- the label is the
/// affordance -- and Material's bar has no configuration that removes them, so
/// building it is less work than fighting it.
///
/// The dot occupies its slot whether or not it is painted, so switching tabs
/// moves no text.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<AppTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const double _dotSize = 5;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);
    final AppTypography type = AppTypography.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.ground,
        border: Border(top: BorderSide(color: palette.hairline)),
      ),
      // Bottom padding comes from the home indicator rather than a constant:
      // the design's 30px is that inset on the device it was drawn for, and
      // hardcoding it would leave a gap on hardware without one.
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.x10,
            bottom: AppSpacing.x10,
          ),
          child: Row(
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selectedIndex,
                    child: GestureDetector(
                      onTap: () => onSelected(i),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.x8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              items[i].label,
                              style: type.tabLabel.copyWith(
                                color: i == selectedIndex
                                    ? palette.textPrimary
                                    : palette.textSecondary,
                              ),
                            ),
                            const SizedBox(height: _dotSize),
                            Container(
                              width: _dotSize,
                              height: _dotSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == selectedIndex
                                    ? palette.accent
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

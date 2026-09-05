import 'package:flutter/material.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/app/theme/app_spacing.dart';
import 'package:mate/app/theme/app_typography.dart';

/// The top of a screen: an optional back link, then an optional title row.
///
/// Not an [AppBar]. The design has no bar -- no background, no bottom border,
/// no fixed height, and the "‹ Friends" link names its destination rather than
/// showing a chevron. Building it as a plain widget in the scroll content is
/// what lets the title scroll away with everything else.
class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    this.title,
    this.backLabel,
    this.onBack,
    this.trailing,
    super.key,
  });

  /// Screen title. Omitted on the board, which has only a back link.
  final String? title;

  /// The destination, not the word "Back" -- "Home", "Friends", "You". The
  /// chevron is added here.
  final String? backLabel;

  final VoidCallback? onBack;

  /// Right-aligned control on the title row -- the "Settings" link on You, the
  /// username on Home.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);
    final AppTypography type = AppTypography.of(context);
    final bool hasBack = backLabel != null && onBack != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (hasBack)
          Semantics(
            button: true,
            child: GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                // Vertical padding rather than a height: it is what carries the
                // link to the 44px tap target the design requires without
                // adding a box around a piece of text.
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.x12),
                child: Text(
                  '‹ $backLabel',
                  style: type.rowPrimaryCompact.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        if (title != null)
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title!,
                  style: type.screenTitle.copyWith(color: palette.textPrimary),
                ),
              ),
              ?trailing,
            ],
          ),
      ],
    );
  }
}

/// The uppercase mono label above a section -- "FRIENDS", "REQUESTS", "MOVES".
///
/// Uppercases its input rather than expecting callers to shout, so a label
/// built from data ("3 FRIENDS") cannot get it half right.
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.of(context).label
          .copyWith(color: AppPalette.of(context).textTertiary),
    );
  }
}

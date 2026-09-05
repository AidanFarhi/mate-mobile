import 'package:flutter/material.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/app/theme/app_spacing.dart';
import 'package:mate/app/theme/app_typography.dart';

/// The app's spinner.
///
/// A thin accent ring. Deliberately small and unlabelled -- it sits inside rows
/// and buttons, where the design has room for a mark and not for copy.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({this.size = 20, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size <= 20 ? 2 : 2.5,
        color: AppPalette.of(context).accent,
      ),
    );
  }
}

/// A whole screen that is still fetching.
///
/// Used for the initial load of a screen, where there is no stale content to
/// show. Once a screen *has* content, prefer leaving it up and showing the
/// spinner in place -- swapping a populated screen for this one is a flash.
class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({this.label, super.key});

  /// Optional line under the spinner, for waits with a known cause
  /// ("Reconnecting…"). Omitted for ordinary fetches, which resolve faster
  /// than the copy can be read.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);
    final AppTypography type = AppTypography.of(context);

    return ColoredBox(
      color: palette.ground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const AppLoadingIndicator(size: 24),
            if (label != null) ...<Widget>[
              const SizedBox(height: AppSpacing.x14),
              Text(
                label!,
                textAlign: TextAlign.center,
                style: type.meta.copyWith(color: palette.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

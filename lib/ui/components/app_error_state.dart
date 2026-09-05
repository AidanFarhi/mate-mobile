import 'package:flutter/material.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/app/theme/app_spacing.dart';
import 'package:mate/app/theme/app_typography.dart';
import 'package:mate/core/error/app_failure.dart';
import 'package:mate/ui/components/app_button.dart';

/// What a screen shows when its fetch failed.
///
/// Takes an [AppFailure] rather than a string so the copy and the retry
/// affordance both come from the failure itself: `userMessage` is already the
/// non-technical wording, and `isRetryable` already answers whether trying
/// again could plausibly work. A retry button on an [UnauthorizedFailure] or a
/// [ValidationFailure] would just fail again the same way, so there is no
/// override for it -- if a case needs one, the failure type is wrong.
class AppErrorState extends StatelessWidget {
  const AppErrorState({required this.failure, this.onRetry, super.key});

  final AppFailure failure;

  /// Wired to the button only when [AppFailure.isRetryable]. Omit it for a
  /// failure the screen cannot re-attempt.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);
    final AppTypography type = AppTypography.of(context);
    final bool canRetry = failure.isRetryable && onRetry != null;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            failure.userMessage,
            textAlign: TextAlign.center,
            style: type.body.copyWith(color: palette.textSecondary),
          ),
          if (canRetry) ...<Widget>[
            const SizedBox(height: AppSpacing.x18),
            AppButton(
              label: 'Try again',
              onPressed: onRetry,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}

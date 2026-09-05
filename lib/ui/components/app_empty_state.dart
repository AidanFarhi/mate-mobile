import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/app/theme/app_spacing.dart';
import 'package:mate/app/theme/app_typography.dart';
import 'package:mate/ui/components/app_button.dart';

/// The dashed card shown where content would be if there were any.
///
/// One treatment for all of them -- no active game, no friends, no history.
/// The dashed outline is what separates "nothing here yet" from "something
/// failed": a solid card would read as content, and bare centered text reads as
/// a broken screen. Errors get [AppErrorState] instead.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// One line, sentence case. "No active game".
  final String title;

  /// Optional second line saying what to do about it.
  final String? message;

  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);
    final AppTypography type = AppTypography.of(context);
    final bool hasAction = actionLabel != null && onAction != null;

    return CustomPaint(
      painter: _DashedBorderPainter(
        color: palette.border,
        radius: AppRadii.activeGameCard,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.x26,
          horizontal: AppSpacing.x18,
        ),
        decoration: BoxDecoration(
          color: palette.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppRadii.activeGameCard),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              textAlign: TextAlign.center,
              style: type.rowPrimary.copyWith(color: palette.textPrimary),
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: AppSpacing.x6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: type.rowSecondary.copyWith(
                  color: palette.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            if (hasAction) ...<Widget>[
              const SizedBox(height: AppSpacing.x18),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                size: AppButtonSize.small,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Strokes a rounded rectangle as a dash pattern.
///
/// Flutter's [Border] cannot dash, and the alternative -- a border image or a
/// package -- is a lot of machinery for the one dashed outline in the design.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final PathMetric metric in path.computeMetrics()) {
      double start = 0;
      while (start < metric.length) {
        final double end = (start + _dash).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        start = end + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

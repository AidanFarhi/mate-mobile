import 'package:flutter/material.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/app/theme/app_spacing.dart';
import 'package:mate/app/theme/app_typography.dart';

/// Which of the four button treatments in the design this is.
enum AppButtonVariant {
  /// Accent fill. Every "do the thing" CTA -- Continue, Challenge, Add.
  primary,

  /// Translucent fill. "Keep playing", and anything paired with a [primary].
  secondary,

  /// Danger fill. Resign, Delete account.
  destructive,

  /// Bone-white fill. Sign in with Apple, and nothing else -- it is the one
  /// button that has to read as a platform affordance rather than as ours.
  light,
}

/// Height, radius and label size, which the design varies together.
enum AppButtonSize {
  /// 52px, radius 14. Full-width screen CTAs.
  large,

  /// 48px, radius 13. Sheet buttons and footer CTAs.
  medium,

  /// 42px, radius 11. The "Add" button beside an input.
  small,
}

/// The app's button.
///
/// Built on [FilledButton] rather than a bare [GestureDetector] so focus,
/// semantics and press feedback come from the framework; only the paint is ours.
///
/// The size enum sets a *minimum* height, never a fixed one. At 200% text the
/// label is taller than the design's 52px and the button has to grow rather
/// than clip -- see the text-scaling test in `test/ui/`.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.expand = true,
    super.key,
  });

  final String label;

  /// `null` disables the button. Every variant shares one disabled treatment,
  /// per the Setup screen's spec -- a disabled destructive button must not
  /// still look dangerous.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Whether to fill the available width. True for the screen CTAs, which is
  /// most of them; the friend-add button is the exception.
  final bool expand;

  double get _minHeight => switch (size) {
    AppButtonSize.large => 52,
    AppButtonSize.medium => 48,
    AppButtonSize.small => 42,
  };

  double get _radius => switch (size) {
    AppButtonSize.large => AppRadii.card,
    AppButtonSize.medium => AppRadii.cta,
    AppButtonSize.small => AppRadii.small,
  };

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);
    final AppTypography type = AppTypography.of(context);

    final (Color background, Color foreground) = switch (variant) {
      AppButtonVariant.primary => (palette.accent, palette.onAccent),
      AppButtonVariant.secondary => (palette.fill, palette.textPrimary),
      AppButtonVariant.destructive => (palette.danger, palette.onDanger),
      AppButtonVariant.light => (palette.textPrimary, palette.onAccent),
    };

    final Widget button = FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.disabled) ? palette.fill : background,
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.disabled)
              ? palette.textTertiary
              : foreground,
        ),
        textStyle: WidgetStatePropertyAll<TextStyle>(
          size == AppButtonSize.small ? type.buttonSmall : type.button,
        ),
        minimumSize: WidgetStatePropertyAll<Size>(Size(0, _minHeight)),
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            horizontal: size == AppButtonSize.small ? 16 : AppSpacing.x20,
            vertical: AppSpacing.x10,
          ),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
        ),
        elevation: const WidgetStatePropertyAll<double>(0),
        // Material would otherwise pad the button out to its own 48px target,
        // which fights the design's explicit heights.
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, textAlign: TextAlign.center),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

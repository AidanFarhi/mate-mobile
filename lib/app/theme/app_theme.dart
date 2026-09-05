import 'package:flutter/material.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/app/theme/app_spacing.dart';
import 'package:mate/app/theme/app_typography.dart';
import 'package:mate/app/theme/board_palette.dart';

/// The app's single theme.
///
/// Dark only, deliberately: `docs/design/ui_design.md` specifies one theme and
/// its token table defines no light values. Inventing a light palette would
/// mean designing a second theme nobody approved. `MateApp` pins `themeMode`
/// so the system setting cannot reach it.
///
/// Three [ThemeExtension]s carry what Material's slots cannot: [AppPalette]
/// (four text tiers, translucent fills, scrims), [AppTypography] (the mono
/// half of the scale), and [BoardPalette] (squares and pieces). The
/// [ColorScheme] and [TextTheme] below are populated from the same tokens so
/// that framework widgets -- dialogs, snackbars, text fields -- are styled
/// without every screen restating the palette.
class AppTheme {
  const AppTheme._();

  static const AppPalette _palette = AppPalette.dark;

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _palette.ground,
    canvasColor: _palette.ground,
    colorScheme: ColorScheme.dark(
      primary: _palette.accent,
      onPrimary: _palette.onAccent,
      secondary: _palette.accent,
      onSecondary: _palette.onAccent,
      surface: _palette.ground,
      onSurface: _palette.textPrimary,
      onSurfaceVariant: _palette.textSecondary,
      surfaceContainer: _palette.surfaceRaised,
      surfaceContainerHigh: _palette.surfaceRaised,
      error: _palette.danger,
      onError: _palette.onDanger,
      outline: _palette.border,
      outlineVariant: _palette.divider,
      scrim: _palette.scrimModal,
    ),
    textTheme: AppTypography.textTheme(_palette.textPrimary),
    extensions: <ThemeExtension<dynamic>>[
      _palette,
      AppTypography.standard,
      BoardPalette.standard,
    ],

    // The design has one shadow (on pieces) and no elevation anywhere, so every
    // surface that Material would tint or lift is flattened here rather than in
    // each screen.
    appBarTheme: AppBarTheme(
      backgroundColor: _palette.ground,
      surfaceTintColor: Colors.transparent,
      foregroundColor: _palette.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.standard.screenTitle.copyWith(
        color: _palette.textPrimary,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: _palette.divider,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _palette.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.sheet)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _palette.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: _palette.scrimSheet,
      elevation: 0,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.sheet)),
      ),
    ),
    // The toast in the design is a floating snackbar: a fixed inset from the
    // bottom so it clears the tab bar, and no action slot. `AppToast` supplies
    // the content and duration; the look lives here so a snackbar raised by
    // anything else still matches.
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _palette.surfaceToast,
      elevation: 0,
      insetPadding: const EdgeInsets.only(
        left: AppSpacing.screenInset,
        right: AppSpacing.screenInset,
        bottom: 110,
      ),
      contentTextStyle: AppTypography.standard.rowSecondary.copyWith(
        color: _palette.textPrimary,
        height: 1.4,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.card)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _palette.surface,
      hintStyle: AppTypography.standard.button.copyWith(
        color: _palette.textTertiary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      border: _inputBorder(_palette.border),
      enabledBorder: _inputBorder(_palette.border),
      focusedBorder: _inputBorder(_palette.accent),
      errorBorder: _inputBorder(_palette.danger),
      focusedErrorBorder: _inputBorder(_palette.danger),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _palette.accent,
      selectionColor: _palette.accentWashStrong,
      selectionHandleColor: _palette.accent,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _palette.accent,
      circularTrackColor: Colors.transparent,
      linearTrackColor: _palette.track,
    ),
    iconTheme: IconThemeData(color: _palette.textPrimary, size: 20),
    listTileTheme: ListTileThemeData(
      iconColor: _palette.textSecondary,
      textColor: _palette.textPrimary,
    ),
  );

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(AppRadii.cta)),
    borderSide: BorderSide(color: color),
  );
}

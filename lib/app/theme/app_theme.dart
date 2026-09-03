import 'package:flutter/material.dart';

/// Minimal dark theme.
///
/// Dark only, deliberately: `docs/ui_design.md` specifies a single dark theme
/// and its token table defines no light values. Inventing a light palette would
/// mean designing a second theme nobody approved.
///
/// This is the floor, not the design system. It sets enough of the palette that
/// nothing flashes white on launch; the full token set -- typography scale,
/// spacing, radii, board colors, shared components -- lands in #3 once the
/// prototype files are in `docs/`.
class AppTheme {
  const AppTheme._();

  /// App background. `ground` in the token table.
  static const Color ground = Color(0xFF1C201A);

  /// Sheets and modals. `surface-raised`.
  static const Color surfaceRaised = Color(0xFF262B24);

  /// `text-primary`.
  static const Color textPrimary = Color(0xFFEDEEE7);

  /// `accent` -- turn dot, CTAs, positive stats.
  static const Color accent = Color(0xFFB4C4A8);

  /// `danger` -- resign, delete, loss chip.
  static const Color danger = Color(0xFFC99B8B);

  /// `on-accent` / `on-light` -- text on [accent] or on light surfaces.
  static const Color onAccent = Color(0xFF14170F);

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ground,
    colorScheme: const ColorScheme.dark(
      surface: ground,
      onSurface: textPrimary,
      surfaceContainerHigh: surfaceRaised,
      primary: accent,
      onPrimary: onAccent,
      error: danger,
      onError: onAccent,
    ),
  );
}

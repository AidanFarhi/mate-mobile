import 'package:flutter/material.dart';

/// The type scale, as a [ThemeExtension].
///
/// Roles are named for what they label in `docs/design/ui_design.md`, not for
/// Material's slots. The scale is a sans/mono split -- mono carries every meta
/// line, label, code and notation -- and [TextTheme] has no slot that means
/// "mono", so the roles live here and screens read them with [AppTypography.of].
///
/// [textTheme] still maps what it can onto Material's slots, so an unstyled
/// [Text], a [SnackBar] or a [Dialog] inherits the right face and size instead
/// of falling back to Roboto.
///
/// Both faces are variable fonts, so every style sets `fontVariations` as well
/// as `fontWeight`. `fontWeight` alone selects a static instance that these
/// files do not contain, and the platform answers with a synthesized -- or
/// simply wrong -- weight.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.wordmark,
    required this.wordmarkSubhead,
    required this.screenTitle,
    required this.sectionTitle,
    required this.statValue,
    required this.body,
    required this.rowPrimary,
    required this.rowPrimaryCompact,
    required this.rowSecondary,
    required this.button,
    required this.buttonSmall,
    required this.tabLabel,
    required this.label,
    required this.labelWide,
    required this.meta,
    required this.metaSmall,
    required this.notation,
    required this.code,
  });

  /// Instrument Sans. Bundled under the OFL -- see `assets/fonts/`.
  static const String sansFamily = 'Instrument Sans';

  /// JetBrains Mono. Bundled under the OFL -- see `assets/fonts/`.
  static const String monoFamily = 'JetBrains Mono';

  /// "Mate" on the Sign In screen. 27/600/-0.02em.
  final TextStyle wordmark;

  /// "MINIMAL CHESS" under the wordmark. Mono, unusually wide tracking.
  final TextStyle wordmarkSubhead;

  /// Screen headings -- "Friends", "Settings". 22/600.
  final TextStyle screenTitle;

  /// Section headings and the Game Detail title. 20/600.
  final TextStyle sectionTitle;

  /// The number on a stat card. 20/600.
  final TextStyle statValue;

  /// Running copy -- taglines, sheet bodies. 15/1.45.
  final TextStyle body;

  /// The primary line of a card or player strip. 15/500.
  final TextStyle rowPrimary;

  /// The primary line of a list row, one step down from [rowPrimary]. 14/500.
  final TextStyle rowPrimaryCompact;

  /// The supporting line under a row primary. 13/1.45.
  final TextStyle rowSecondary;

  /// Call-to-action labels. 16/500.
  final TextStyle button;

  /// Chip and small-button labels. 13/500.
  final TextStyle buttonSmall;

  /// Bottom tab bar labels. 12/500, the only role between [buttonSmall] and
  /// [rowPrimaryCompact].
  final TextStyle tabLabel;

  /// Mono section labels -- "FRIENDS", "MOVES". Uppercase is the caller's job;
  /// the design capitalizes the source string rather than transforming it.
  final TextStyle label;

  /// [label] with the wide tracking used by the Sign In subhead and nothing
  /// else on a section header.
  final TextStyle labelWide;

  /// Mono meta lines -- "move 12 · untimed". 11/400.
  final TextStyle meta;

  /// The smallest mono line -- head-to-head records, game summaries. 10/400.
  final TextStyle metaSmall;

  /// SAN move notation in Game Detail. 13/400.
  final TextStyle notation;

  /// The friend code. Mono, medium, widely tracked so it reads as a token.
  final TextStyle code;

  static TextStyle _sans(
    double size,
    int weight, {
    double? height,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: sansFamily,
    fontSize: size,
    height: height,
    letterSpacing: letterSpacing,
    fontWeight: FontWeight.values[weight ~/ 100 - 1],
    fontVariations: <FontVariation>[FontVariation('wght', weight.toDouble())],
  );

  static TextStyle _mono(
    double size,
    int weight, {
    double? height,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: monoFamily,
    fontSize: size,
    height: height,
    letterSpacing: letterSpacing,
    fontWeight: FontWeight.values[weight ~/ 100 - 1],
    fontVariations: <FontVariation>[FontVariation('wght', weight.toDouble())],
  );

  /// The app's only type scale.
  ///
  /// Tracking is in logical pixels here and in `em` in the design doc; each
  /// value below is the doc's `em` figure multiplied by its own font size.
  static final AppTypography standard = AppTypography(
    wordmark: _sans(27, 600, height: 1.15, letterSpacing: -0.54),
    wordmarkSubhead: _mono(11, 500, letterSpacing: 1.76),
    screenTitle: _sans(22, 600, letterSpacing: -0.22),
    sectionTitle: _sans(20, 600, letterSpacing: -0.2),
    statValue: _sans(20, 600),
    body: _sans(15, 400, height: 1.45),
    rowPrimary: _sans(15, 500),
    rowPrimaryCompact: _sans(14, 500),
    rowSecondary: _sans(13, 400, height: 1.45),
    button: _sans(16, 500),
    buttonSmall: _sans(13, 500),
    tabLabel: _sans(12, 500, letterSpacing: 0.24),
    label: _mono(11, 500, letterSpacing: 0.66),
    labelWide: _mono(11, 500, letterSpacing: 1.1),
    meta: _mono(11, 400),
    metaSmall: _mono(10, 400),
    notation: _mono(13, 400),
    code: _mono(13, 500, letterSpacing: 1.3),
  );

  /// The type scale for [context]. See [AppPalette.of] on why this asserts.
  static AppTypography of(BuildContext context) {
    final AppTypography? type = Theme.of(context).extension<AppTypography>();
    assert(
      type != null,
      'AppTypography missing -- theme is not AppTheme.dark.',
    );
    return type ?? standard;
  }

  /// Material's slots, filled from the roles above so framework widgets pick up
  /// the right face. Only the sans roles map; there is no Material slot that
  /// means "mono", which is the reason this extension exists.
  static TextTheme textTheme(Color primary) => TextTheme(
    headlineLarge: standard.wordmark,
    headlineMedium: standard.screenTitle,
    headlineSmall: standard.sectionTitle,
    titleLarge: standard.screenTitle,
    titleMedium: standard.rowPrimary,
    titleSmall: standard.rowPrimaryCompact,
    bodyLarge: standard.body,
    bodyMedium: standard.rowSecondary,
    bodySmall: standard.meta,
    labelLarge: standard.button,
    labelMedium: standard.buttonSmall,
    labelSmall: standard.label,
  ).apply(bodyColor: primary, displayColor: primary);

  // See AppPalette: one fixed theme, so neither method ever runs.
  @override
  AppTypography copyWith() => this;

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) =>
      other is AppTypography && t >= 0.5 ? other : this;
}

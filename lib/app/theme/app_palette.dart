import 'package:flutter/material.dart';

/// Every color in the app, as a [ThemeExtension].
///
/// The token table in `docs/design/ui_design.md` is wider than [ColorScheme] --
/// it has four text tiers, five translucent fills and two scrims. Rather than
/// bend those onto Material slots that mean something else, they live here and
/// screens read them with [AppPalette.of]. What *does* map cleanly onto
/// [ColorScheme] is set there too, so Material's own widgets are still styled.
///
/// The translucent tokens are all the same bone white at different alphas. They
/// are spelled out one by one instead of generated from a scale because the
/// design uses specific values (.04, .055, .07, .09, .10, .12, .14) that are not
/// a progression -- deriving them would invent a system the design does not have.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.ground,
    required this.surface,
    required this.surfaceSubtle,
    required this.surfaceRaised,
    required this.surfaceToast,
    required this.fill,
    required this.fillSoft,
    required this.avatarFill,
    required this.track,
    required this.hairline,
    required this.divider,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textQuaternary,
    required this.accent,
    required this.accentWashSoft,
    required this.accentWash,
    required this.accentWashStrong,
    required this.accentBorder,
    required this.danger,
    required this.dangerWash,
    required this.onAccent,
    required this.onDanger,
    required this.scrimSheet,
    required this.scrimModal,
  });

  /// App background and tab bar. `ground`.
  final Color ground;

  /// Cards, stat tiles, inputs. `surface`.
  final Color surface;

  /// The dashed empty-state card, one step quieter than [surface].
  final Color surfaceSubtle;

  /// Sheets and modals. `surface-raised`.
  final Color surfaceRaised;

  /// Toast background. `surface-toast`.
  final Color surfaceToast;

  /// Secondary buttons and disabled CTAs.
  final Color fill;

  /// Unselected cells in the profile-icon grid.
  final Color fillSoft;

  /// Avatar circles for anyone who is not the signed-in user.
  final Color avatarFill;

  /// The unfilled remainder of the head-to-head bar.
  final Color track;

  /// Card borders. `hairline`, upper end of its range.
  final Color hairline;

  /// Row dividers. `hairline`, lower end of its range.
  final Color divider;

  /// Text-input borders -- the only stroke in the design heavier than a
  /// hairline, so a field reads as interactive rather than as a card.
  final Color border;

  /// Names, titles, values. `text-primary`.
  final Color textPrimary;

  /// Body copy and captured pieces. `text-secondary`.
  final Color textSecondary;

  /// Mono meta lines. `text-tertiary`.
  final Color textTertiary;

  /// Footnotes and the version stamp. `text-quaternary`.
  final Color textQuaternary;

  /// Turn dot, CTAs, positive stats, active tab dot. `accent`.
  final Color accent;

  /// Head-to-head panel background. `accent-wash`, .10.
  final Color accentWashSoft;

  /// Challenge chip background. `accent-wash`, .16.
  final Color accentWash;

  /// Win chip background. `accent-wash`, .22.
  final Color accentWashStrong;

  /// Head-to-head panel border.
  final Color accentBorder;

  /// Resign, delete, loss chip. `danger`.
  final Color danger;

  /// Loss chip background.
  final Color dangerWash;

  /// Text on [accent] or on a bone-white surface. `on-accent` / `on-light`.
  final Color onAccent;

  /// Text on [danger]. Darker than [onAccent] because the danger fill is
  /// warmer and needs more contrast to read as ink rather than as shadow.
  final Color onDanger;

  /// Bottom-sheet scrim.
  final Color scrimSheet;

  /// Modal scrim, one step heavier than [scrimSheet].
  final Color scrimModal;

  /// The app's only palette. There is no light variant to write -- see
  /// `docs/adr/0001-state-management-and-routing.md` and #3.
  static const AppPalette dark = AppPalette(
    ground: Color(0xFF1C201A),
    surface: Color.fromRGBO(237, 238, 231, 0.055),
    surfaceSubtle: Color.fromRGBO(237, 238, 231, 0.04),
    surfaceRaised: Color(0xFF262B24),
    surfaceToast: Color(0xFF3A4235),
    fill: Color.fromRGBO(237, 238, 231, 0.09),
    fillSoft: Color.fromRGBO(237, 238, 231, 0.07),
    avatarFill: Color.fromRGBO(237, 238, 231, 0.10),
    track: Color.fromRGBO(237, 238, 231, 0.12),
    hairline: Color.fromRGBO(237, 238, 231, 0.09),
    divider: Color.fromRGBO(237, 238, 231, 0.08),
    border: Color.fromRGBO(237, 238, 231, 0.14),
    textPrimary: Color(0xFFEDEEE7),
    textSecondary: Color.fromRGBO(237, 238, 231, 0.5),
    textTertiary: Color.fromRGBO(237, 238, 231, 0.35),
    textQuaternary: Color.fromRGBO(237, 238, 231, 0.3),
    accent: Color(0xFFB4C4A8),
    accentWashSoft: Color.fromRGBO(180, 196, 168, 0.10),
    accentWash: Color.fromRGBO(180, 196, 168, 0.16),
    accentWashStrong: Color.fromRGBO(180, 196, 168, 0.22),
    accentBorder: Color.fromRGBO(180, 196, 168, 0.20),
    danger: Color(0xFFC99B8B),
    dangerWash: Color.fromRGBO(201, 155, 139, 0.18),
    onAccent: Color(0xFF14170F),
    onDanger: Color(0xFF20140F),
    scrimSheet: Color.fromRGBO(8, 10, 7, 0.66),
    scrimModal: Color.fromRGBO(8, 10, 7, 0.72),
  );

  /// The palette for [context].
  ///
  /// Asserts rather than silently defaulting: a missing extension means the app
  /// was not wrapped in [AppTheme], and rendering in colors nobody chose is
  /// worse than a loud failure in debug.
  static AppPalette of(BuildContext context) {
    final AppPalette? palette = Theme.of(context).extension<AppPalette>();
    assert(
      palette != null,
      'AppPalette missing -- theme is not AppTheme.dark.',
    );
    return palette ?? dark;
  }

  // One fixed theme means there is never a second palette to copy from or
  // interpolate toward, and no frame will ever run either method. Implementing
  // them properly would cost ~80 lines of parameter list whose only purpose is
  // to satisfy the base class.
  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) =>
      other is AppPalette && t >= 0.5 ? other : this;
}

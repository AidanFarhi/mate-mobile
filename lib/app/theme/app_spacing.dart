/// Spacing, radii, and the two fixed sizes the design pins.
///
/// Plain constants rather than a [ThemeExtension]: unlike colors and type,
/// these do not vary with anything, and threading a [BuildContext] through
/// every `EdgeInsets` to read a value that cannot change buys nothing.
///
/// The spacing values are named for their magnitude, not their role. The design
/// uses 2/3/6/8/10/11/12/14/18/20/22/26 -- not a progression, so a `sm/md/lg`
/// naming would have to invent an ordering the design does not have, and the
/// first screen needing 11 where the scale says 12 would break it.
class AppSpacing {
  const AppSpacing._();

  static const double x2 = 2;
  static const double x3 = 3;
  static const double x6 = 6;
  static const double x8 = 8;
  static const double x10 = 10;
  static const double x11 = 11;
  static const double x12 = 12;
  static const double x14 = 14;
  static const double x18 = 18;
  static const double x20 = 20;
  static const double x22 = 22;
  static const double x26 = 26;

  /// Standard screen side inset. Setup uses 24 and Sign In 28; the board is
  /// full-bleed and uses none.
  static const double screenInset = 20;

  /// Distance from the safe-area top to the first content on a pushed or tab
  /// screen. The design quotes 66 against a 59px inset, so this is what remains
  /// once `SafeArea` has taken its share.
  static const double screenTop = 7;

  /// Minimum height of anything tappable. Rows and chips in the design are
  /// already at or above this; it is here so nothing new drops below it.
  static const double minTapTarget = 44;
}

/// Corner radii. Each value has one use in the design, so these are named for
/// the role rather than the number.
class AppRadii {
  const AppRadii._();

  /// The board has square corners, deliberately -- it is full-bleed.
  static const double board = 0;

  /// Result chip.
  static const double chip = 8;

  /// Small inputs and buttons -- the friend-add row.
  static const double small = 11;

  /// Call-to-action buttons and sheet buttons.
  static const double cta = 13;

  /// Cards, stat tiles, and the toast.
  static const double card = 14;

  /// The friend-add card.
  static const double addCard = 16;

  /// The active-game card, the largest card radius.
  static const double activeGameCard = 18;

  /// Fully rounded pills -- the Resign chip, the Challenge chip.
  static const double pill = 20;

  /// Bottom sheets and the result modal.
  static const double sheet = 22;
}

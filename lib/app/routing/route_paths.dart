/// Every route in the app, in one place.
///
/// The set follows the nine screens in `docs/ui_design.md`. Two notes on how it
/// differs from the original list in #2:
///
/// * There is no `/history`. The UI spec folds game history into the "You"
///   screen, so [you] is that screen and history is a section within it.
/// * [game] serves both a live board and a finished game's notation. One game
///   has one URL; the screen branches on the game's status.
class RoutePaths {
  const RoutePaths._();

  /// Bootstrap screen shown while [AuthStatus.unknown] is being resolved.
  static const String splash = '/splash';

  static const String signIn = '/sign-in';
  static const String profileSetup = '/profile-setup';

  // Tab destinations. These three sit inside the shell that draws the bottom
  // bar; everything else covers it.
  static const String home = '/';
  static const String friends = '/friends';
  static const String you = '/you';

  // Pushed views, outside the shell.
  static const String friendProfile = '/friends/:username';
  static const String game = '/game/:id';
  static const String settings = '/settings';

  /// Screens reachable without a complete, authenticated profile. Used by the
  /// redirect to decide when a signed-in user is somewhere they should not be.
  static const Set<String> preAuth = <String>{splash, signIn, profileSetup};

  static String friendProfileFor(String username) => '/friends/$username';

  static String gameFor(String id) => '/game/$id';
}

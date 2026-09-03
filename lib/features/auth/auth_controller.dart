import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mate/core/log/app_logger.dart';
import 'package:mate/features/auth/auth_status.dart';

/// Owns [AuthStatus] for the whole app.
///
/// This is the seam between routing and authentication. The router reads it and
/// nothing else; #5 (Sign in with Apple) and #6 (session persistence) replace
/// the bodies below with real Keychain and token work without the router
/// changing.
///
/// Everything here is deliberately a stub. [bootstrap] resolves to signed-out
/// rather than pretending to restore a session, so the redirect logic and its
/// tests are exercisable today.
class AuthController extends Notifier<AuthStatus> {
  AuthController({this.initialStatus = AuthStatus.unknown});

  /// Starting state. Overridden in tests to pin a specific auth state.
  final AuthStatus initialStatus;

  static const AppLogger _log = AppLogger('auth');

  @override
  AuthStatus build() => initialStatus;

  /// Resolves the launch state. Called once at startup.
  ///
  /// #6 replaces this with: read the refresh token from the Keychain, exchange
  /// it, and resolve to [AuthStatus.signedIn], [AuthStatus.needsProfileSetup],
  /// or [AuthStatus.signedOut] based on the result.
  Future<void> bootstrap() async {
    _log.debug('bootstrap: no session store yet, resolving to signedOut');
    state = AuthStatus.signedOut;
  }

  /// Called by #5 once the backend has accepted an Apple identity token.
  ///
  /// [hasProfile] reflects whether the user already picked a username and icon;
  /// a brand-new Apple ID has not, and lands on Profile Setup.
  void onAuthenticated({required bool hasProfile}) {
    state = hasProfile ? AuthStatus.signedIn : AuthStatus.needsProfileSetup;
    _log.info('authenticated (hasProfile: $hasProfile) -> $state');
  }

  /// Called by #7 when the user completes username + icon selection.
  void onProfileCompleted() {
    state = AuthStatus.signedIn;
    _log.info('profile completed -> $state');
  }

  /// Clears the session. #6 adds Keychain and cache clearing; the state change
  /// alone is what pushes the router back to Sign In.
  void signOut() {
    state = AuthStatus.signedOut;
    _log.info('signed out');
  }
}

final NotifierProvider<AuthController, AuthStatus> authControllerProvider =
    NotifierProvider<AuthController, AuthStatus>(AuthController.new);

import 'package:mate/app/routing/route_paths.dart';
import 'package:mate/features/auth/auth_status.dart';

/// Decides where an [AuthStatus] is allowed to be.
///
/// Kept as a pure function, separate from the `GoRouter` that calls it, so the
/// whole matrix is unit-testable without pumping a widget tree.
///
/// The invariant that matters: every branch either returns `null` or a location
/// that itself returns `null` on the next pass. That is what makes redirect
/// loops -- the classic bug in auth-gated routers -- impossible rather than
/// merely untested.
///
/// Returns `null` to allow [location], or the path to send the user to instead.
String? resolveAuthRedirect({
  required AuthStatus status,
  required String location,
}) {
  return switch (status) {
    // Still resolving the session. Park on the splash and decide nothing.
    AuthStatus.unknown =>
      location == RoutePaths.splash ? null : RoutePaths.splash,

    // No session: Sign In is the only reachable screen.
    AuthStatus.signedOut =>
      location == RoutePaths.signIn ? null : RoutePaths.signIn,

    // Authenticated but incomplete. Note this also traps the user *inside*
    // setup: they cannot skip it by navigating away, which is the point.
    AuthStatus.needsProfileSetup =>
      location == RoutePaths.profileSetup ? null : RoutePaths.profileSetup,

    // Fully signed in: bounce off the pre-auth screens, allow everything else.
    AuthStatus.signedIn =>
      RoutePaths.preAuth.contains(location) ? RoutePaths.home : null,
  };
}

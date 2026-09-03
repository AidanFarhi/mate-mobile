import 'package:flutter_test/flutter_test.dart';
import 'package:mate/app/routing/auth_redirect.dart';
import 'package:mate/app/routing/route_paths.dart';
import 'package:mate/features/auth/auth_status.dart';

/// Every route a user can be at, used to prove the redirect is total: no
/// status/location pair falls through unhandled or loops.
const List<String> _allLocations = <String>[
  RoutePaths.splash,
  RoutePaths.signIn,
  RoutePaths.profileSetup,
  RoutePaths.home,
  RoutePaths.friends,
  RoutePaths.you,
  '/friends/mira.k',
  '/game/abc123',
  RoutePaths.settings,
];

void main() {
  group('unknown', () {
    test('parks on the splash from anywhere else', () {
      for (final String location in _allLocations) {
        if (location == RoutePaths.splash) continue;
        expect(
          resolveAuthRedirect(status: AuthStatus.unknown, location: location),
          RoutePaths.splash,
          reason: 'from $location',
        );
      }
    });

    test('allows the splash itself', () {
      expect(
        resolveAuthRedirect(
          status: AuthStatus.unknown,
          location: RoutePaths.splash,
        ),
        isNull,
      );
    });
  });

  group('signedOut', () {
    test('redirects every protected route to sign-in', () {
      for (final String location in _allLocations) {
        if (location == RoutePaths.signIn) continue;
        expect(
          resolveAuthRedirect(status: AuthStatus.signedOut, location: location),
          RoutePaths.signIn,
          reason: 'from $location',
        );
      }
    });

    test('allows sign-in itself', () {
      expect(
        resolveAuthRedirect(
          status: AuthStatus.signedOut,
          location: RoutePaths.signIn,
        ),
        isNull,
      );
    });
  });

  group('needsProfileSetup', () {
    test('traps the user in profile setup', () {
      for (final String location in _allLocations) {
        if (location == RoutePaths.profileSetup) continue;
        expect(
          resolveAuthRedirect(
            status: AuthStatus.needsProfileSetup,
            location: location,
          ),
          RoutePaths.profileSetup,
          reason: 'from $location',
        );
      }
    });

    test('allows profile setup itself', () {
      expect(
        resolveAuthRedirect(
          status: AuthStatus.needsProfileSetup,
          location: RoutePaths.profileSetup,
        ),
        isNull,
      );
    });
  });

  group('signedIn', () {
    test('bounces off every pre-auth screen to home', () {
      for (final String location in RoutePaths.preAuth) {
        expect(
          resolveAuthRedirect(status: AuthStatus.signedIn, location: location),
          RoutePaths.home,
          reason: 'from $location',
        );
      }
    });

    test('passes through every authenticated route', () {
      for (final String location in _allLocations) {
        if (RoutePaths.preAuth.contains(location)) continue;
        expect(
          resolveAuthRedirect(status: AuthStatus.signedIn, location: location),
          isNull,
          reason: 'from $location',
        );
      }
    });
  });

  // The property that makes redirect loops impossible: whatever the redirect
  // returns must itself be allowed. Without this, a wrong target ping-pongs
  // until GoRouter gives up with a redirect-limit error.
  test('no status can produce a redirect loop', () {
    for (final AuthStatus status in AuthStatus.values) {
      for (final String location in _allLocations) {
        final String? target = resolveAuthRedirect(
          status: status,
          location: location,
        );
        if (target == null) continue;

        expect(
          resolveAuthRedirect(status: status, location: target),
          isNull,
          reason: '$status sent $location -> $target, which redirects again',
        );
      }
    }
  });
}

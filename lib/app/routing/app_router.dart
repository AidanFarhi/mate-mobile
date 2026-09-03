import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mate/app/routing/auth_redirect.dart';
import 'package:mate/app/routing/placeholder_screen.dart';
import 'package:mate/app/routing/route_paths.dart';
import 'package:mate/app/routing/tab_shell.dart';
import 'package:mate/core/log/app_logger.dart';
import 'package:mate/features/auth/auth_controller.dart';
import 'package:mate/features/auth/auth_status.dart';

const AppLogger _log = AppLogger('router');

/// The app's router.
///
/// Built once and never rebuilt: the provider does not `watch` auth state, it
/// bridges it to a [ValueNotifier] that `GoRouter` listens to. Watching would
/// throw away the navigation stack on every sign-in.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<AuthStatus> refresh = ValueNotifier<AuthStatus>(
    ref.read(authControllerProvider),
  );
  ref.listen(authControllerProvider, (AuthStatus? _, AuthStatus next) {
    refresh.value = next;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthStatus status = ref.read(authControllerProvider);
      final String? target = resolveAuthRedirect(
        status: status,
        location: state.matchedLocation,
      );
      if (target != null) {
        _log.debug('$status: ${state.matchedLocation} -> $target');
      }
      return target;
    },
    routes: <RouteBase>[
      // Pre-auth and pushed views: full screen, no tab bar.
      GoRoute(
        path: RoutePaths.splash,
        builder: (_, _) =>
            const PlaceholderScreen(title: 'Splash', issue: '#6'),
      ),
      GoRoute(
        path: RoutePaths.signIn,
        builder: (_, _) =>
            const PlaceholderScreen(title: 'Sign In', issue: '#5'),
      ),
      GoRoute(
        path: RoutePaths.profileSetup,
        builder: (_, _) =>
            const PlaceholderScreen(title: 'Profile Setup', issue: '#7'),
      ),
      GoRoute(
        path: RoutePaths.friendProfile,
        builder: (_, GoRouterState state) => PlaceholderScreen(
          title: 'Friend: ${state.pathParameters['username']}',
          issue: '#20',
        ),
      ),
      GoRoute(
        path: RoutePaths.game,
        // Live board (#18) and finished-game notation (#21) share this route;
        // the screen branches on the game's status once it is fetched.
        builder: (_, GoRouterState state) => PlaceholderScreen(
          title: 'Game: ${state.pathParameters['id']}',
          issue: '#18 / #21',
        ),
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (_, _) =>
            const PlaceholderScreen(title: 'Settings', issue: '#8'),
      ),

      // Tab destinations.
      ShellRoute(
        builder: (_, _, Widget child) => TabShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: RoutePaths.home,
            builder: (_, _) =>
                const PlaceholderScreen(title: 'Home', issue: '#12'),
          ),
          GoRoute(
            path: RoutePaths.friends,
            builder: (_, _) =>
                const PlaceholderScreen(title: 'Friends', issue: '#11'),
          ),
          GoRoute(
            path: RoutePaths.you,
            builder: (_, _) =>
                const PlaceholderScreen(title: 'You', issue: '#19'),
          ),
        ],
      ),
    ],
  );
});

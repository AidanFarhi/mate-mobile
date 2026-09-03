import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mate/app/routing/route_paths.dart';
import 'package:mate/features/auth/auth_controller.dart';
import 'package:mate/features/auth/auth_status.dart';

/// Debug-only control for driving auth state and pushed routes by hand.
///
/// Until #5 lands there is no way to sign in, so [AuthStatus.signedOut] is the
/// only state a running app can reach and most of the router is unreachable in
/// the simulator. This makes the whole route table walkable.
///
/// Deliberately drives the real [AuthController] methods rather than a debug
/// setter, so what you exercise here is the same path #5 and #7 will call.
///
/// Compiled out of release builds: the whole widget returns nothing when
/// [kReleaseMode] is set. Delete this file once #5 and #6 make it redundant.
class DebugAuthBar extends ConsumerWidget {
  const DebugAuthBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthStatus status = ref.watch(authControllerProvider);
    final AuthController auth = ref.read(authControllerProvider.notifier);
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'DEBUG · auth: ${status.name}',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              _Chip(
                label: 'signedOut',
                onTap: auth.signOut,
                selected: status == AuthStatus.signedOut,
              ),
              _Chip(
                label: 'needsProfileSetup',
                onTap: () => auth.onAuthenticated(hasProfile: false),
                selected: status == AuthStatus.needsProfileSetup,
              ),
              _Chip(
                label: 'signedIn',
                onTap: () => auth.onAuthenticated(hasProfile: true),
                selected: status == AuthStatus.signedIn,
              ),
            ],
          ),
          // Pushed routes are only reachable once the redirect stops
          // intercepting them.
          if (status == AuthStatus.signedIn) ...<Widget>[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                _Chip(
                  label: 'push /settings',
                  onTap: () => context.push(RoutePaths.settings),
                ),
                _Chip(
                  label: 'push /friends/mira.k',
                  onTap: () =>
                      context.push(RoutePaths.friendProfileFor('mira.k')),
                ),
                _Chip(
                  label: 'push /game/demo',
                  onTap: () => context.push(RoutePaths.gameFor('demo')),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

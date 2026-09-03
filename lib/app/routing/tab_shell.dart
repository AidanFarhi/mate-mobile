import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mate/app/routing/route_paths.dart';

/// Bottom tab bar wrapping the three top-level destinations.
///
/// Structure only -- the styling in `docs/ui_design.md` (label sizes, the 5px
/// accent dot under the active tab, the hairline top border) lands with the
/// design system in #3.
///
/// A plain [ShellRoute] rather than a [StatefulShellRoute]: the latter's value
/// is per-tab back stacks, and the UI spec says back "returns to the pusher,
/// defaulting to Home" -- plain pop semantics that do not need nested
/// navigators.
class TabShell extends StatelessWidget {
  const TabShell({required this.child, super.key});

  final Widget child;

  static const List<({String path, String label})> _tabs =
      <({String path, String label})>[
        (path: RoutePaths.home, label: 'Play'),
        (path: RoutePaths.friends, label: 'Friends'),
        (path: RoutePaths.you, label: 'You'),
      ];

  int _indexOf(String location) {
    final int index = _tabs.indexWhere(
      (({String path, String label}) tab) => tab.path == location,
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexOf(location),
        onDestinationSelected: (int index) => context.go(_tabs[index].path),
        destinations: <Widget>[
          for (final (path: _, label: String label) in _tabs)
            NavigationDestination(
              icon: const Icon(Icons.circle_outlined),
              label: label,
            ),
        ],
      ),
    );
  }
}

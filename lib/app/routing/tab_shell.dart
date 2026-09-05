import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mate/app/routing/route_paths.dart';
import 'package:mate/ui/components/app_tab_bar.dart';

/// Bottom tab bar wrapping the three top-level destinations.
///
/// Routing only. The bar itself is [AppTabBar] in the design system, so this
/// widget owns the mapping from location to index and nothing about the paint.
///
/// A plain [ShellRoute] rather than a [StatefulShellRoute]: the latter's value
/// is per-tab back stacks, and the UI spec says back "returns to the pusher,
/// defaulting to Home" -- plain pop semantics that do not need nested
/// navigators.
class TabShell extends StatelessWidget {
  const TabShell({required this.child, super.key});

  final Widget child;

  static const List<AppTabItem> _tabs = <AppTabItem>[
    AppTabItem(label: 'Play', route: RoutePaths.home),
    AppTabItem(label: 'Friends', route: RoutePaths.friends),
    AppTabItem(label: 'You', route: RoutePaths.you),
  ];

  int _indexOf(String location) {
    final int index = _tabs.indexWhere(
      (AppTabItem tab) => tab.route == location,
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      body: child,
      bottomNavigationBar: AppTabBar(
        items: _tabs,
        selectedIndex: _indexOf(location),
        onSelected: (int index) => context.go(_tabs[index].route),
      ),
    );
  }
}

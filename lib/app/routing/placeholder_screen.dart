import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mate/app/routing/debug_auth_bar.dart';

/// Stand-in for a screen that has not been built yet.
///
/// Every route resolves to one of these so the router and its redirects can be
/// exercised end to end before any feature work lands. Each is replaced by the
/// issue named in [issue].
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.issue,
    super.key,
  });

  final String title;

  /// The issue that replaces this screen, e.g. `#12`.
  final String issue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool canPop = GoRouter.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (canPop)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('‹ Back'),
                ),
              ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Arrives in $issue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Compiled out of release builds entirely.
            if (kDebugMode) const DebugAuthBar(),
          ],
        ),
      ),
    );
  }
}

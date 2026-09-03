import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mate/app/routing/app_router.dart';
import 'package:mate/app/theme/app_theme.dart';

/// Root application widget.
///
/// Dark theme is forced rather than following the system: the design specifies
/// one theme, so `theme` and `darkTheme` are the same and `themeMode` pins it.
class MateApp extends ConsumerWidget {
  const MateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Mate',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}

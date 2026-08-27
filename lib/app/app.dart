import 'package:flutter/material.dart';
import 'package:mate/app/placeholder_home_screen.dart';

/// Root application widget.
///
/// State management and routing arrive in #2, the real theme in #3. This is
/// the minimum needed to get a screen onto the simulator.
class MateApp extends StatelessWidget {
  const MateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F2933)),
      ),
      home: const PlaceholderHomeScreen(),
    );
  }
}

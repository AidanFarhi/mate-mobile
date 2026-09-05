import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/app/theme/app_theme.dart';

/// Pumps [child] inside the real app theme.
///
/// Every component test goes through this rather than a bare [MaterialApp]:
/// the components read their colors and type from theme extensions, so a
/// default theme would exercise only the assert-and-fall-back path in
/// `AppPalette.of` and prove nothing about what ships.
Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

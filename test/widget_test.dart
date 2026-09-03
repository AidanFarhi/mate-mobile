import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/app/app.dart';
import 'package:mate/features/auth/auth_controller.dart';
import 'package:mate/features/auth/auth_status.dart';

/// Boots the app with auth pinned to [status].
Widget _appWith(AuthStatus status) {
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(
        () => AuthController(initialStatus: status),
      ),
    ],
    child: const MateApp(),
  );
}

void main() {
  // The redirect matrix is covered exhaustively as pure unit tests in
  // test/app/routing/auth_redirect_test.dart. These only prove the router is
  // actually wired to it.
  testWidgets('unknown auth state lands on the splash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_appWith(AuthStatus.unknown));
    await tester.pumpAndSettle();

    expect(find.text('Splash'), findsOneWidget);
  });

  testWidgets('signed-out lands on sign-in', (WidgetTester tester) async {
    await tester.pumpWidget(_appWith(AuthStatus.signedOut));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('incomplete profile lands on profile setup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_appWith(AuthStatus.needsProfileSetup));
    await tester.pumpAndSettle();

    expect(find.text('Profile Setup'), findsOneWidget);
  });

  testWidgets('signed-in lands on home inside the tab shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_appWith(AuthStatus.signedIn));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    // The tab bar is present on a tab destination.
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });

  testWidgets('signing out returns to sign-in', (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(
          () => AuthController(initialStatus: AuthStatus.signedIn),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MateApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);

    container.read(authControllerProvider.notifier).signOut();
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });
}

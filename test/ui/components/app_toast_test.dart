import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/app/theme/app_theme.dart';
import 'package:mate/core/error/app_failure.dart';
import 'package:mate/ui/components/app_toast.dart';

/// Pumps a screen whose only content is a button that raises [onTap]'s toast.
Future<void> pumpToaster(
  WidgetTester tester,
  void Function(BuildContext context) onTap,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => onTap(context),
            child: const Text('raise'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a toast appears and dismisses itself', (
    WidgetTester tester,
  ) async {
    await pumpToaster(
      tester,
      (BuildContext context) => AppToast.show(context, 'mira.k is a friend.'),
    );
    await tester.tap(find.text('raise'));
    // Two pumps: one to schedule the snackbar, one to run its entrance. The
    // dismiss timer only starts once the entrance finishes.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));
    expect(find.text('mira.k is a friend.'), findsOneWidget);

    await tester.pump(AppToast.duration);
    await tester.pumpAndSettle();
    expect(find.text('mira.k is a friend.'), findsNothing);
  });

  testWidgets('a second toast replaces the first rather than queueing', (
    WidgetTester tester,
  ) async {
    // Three failed moves in a row should say what just happened, not spend
    // seven seconds replaying the first two.
    await pumpToaster(tester, (BuildContext context) {
      AppToast.show(context, 'first');
      AppToast.show(context, 'second');
    });
    await tester.tap(find.text('raise'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('first'), findsNothing);
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('showFailure shows userMessage, never the server message', (
    WidgetTester tester,
  ) async {
    const AppFailure failure = ConflictFailure(
      message: 'You already have an active game. Finish it first.',
    );
    await pumpToaster(
      tester,
      (BuildContext context) => AppToast.showFailure(context, failure),
    );
    await tester.tap(find.text('raise'));
    await tester.pump();

    expect(find.text(failure.userMessage), findsOneWidget);
  });

  testWidgets('the toast is themed, not Material default', (
    WidgetTester tester,
  ) async {
    await pumpToaster(
      tester,
      (BuildContext context) => AppToast.show(context, 'hello'),
    );
    await tester.tap(find.text('raise'));
    await tester.pump();

    final SnackBar bar = tester.widget<SnackBar>(find.byType(SnackBar));
    final SnackBarThemeData theme = AppTheme.dark.snackBarTheme;
    expect(bar.action, isNull, reason: 'the design toast has no action slot');
    expect(theme.backgroundColor, AppPalette.dark.surfaceToast);
    expect(theme.behavior, SnackBarBehavior.floating);
  });
}

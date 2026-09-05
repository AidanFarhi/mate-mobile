import 'package:flutter_test/flutter_test.dart';
import 'package:mate/core/error/app_failure.dart';
import 'package:mate/ui/components/app_button.dart';
import 'package:mate/ui/components/app_error_state.dart';

import '../../support/pump_theme.dart';

void main() {
  const List<AppFailure> failures = <AppFailure>[
    NetworkFailure(),
    UnauthorizedFailure(),
    ValidationFailure(),
    ConflictFailure(),
    ServerFailure(),
    UnknownFailure(),
  ];

  testWidgets('the retry button tracks isRetryable, not the callback', (
    WidgetTester tester,
  ) async {
    // Every failure below is given an onRetry. Offering the button anyway on a
    // non-retryable failure would invite the user to re-run something that
    // fails identically -- an expired session does not un-expire.
    for (final AppFailure failure in failures) {
      await pumpThemed(tester, AppErrorState(failure: failure, onRetry: () {}));
      expect(
        find.byType(AppButton),
        failure.isRetryable ? findsOneWidget : findsNothing,
        reason: '${failure.runtimeType} offered the wrong affordance',
      );
    }
  });

  testWidgets('no retry button without a callback, even when retryable', (
    WidgetTester tester,
  ) async {
    await pumpThemed(tester, const AppErrorState(failure: NetworkFailure()));
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('the copy shown is userMessage, never the server message', (
    WidgetTester tester,
  ) async {
    const AppFailure failure = ServerFailure(
      message: 'pq: duplicate key value violates unique constraint',
    );
    await pumpThemed(tester, const AppErrorState(failure: failure));
    expect(find.text(failure.userMessage), findsOneWidget);
    expect(find.textContaining('pq:'), findsNothing);
  });

  testWidgets('retry fires the callback', (WidgetTester tester) async {
    int retries = 0;
    await pumpThemed(
      tester,
      AppErrorState(failure: const NetworkFailure(), onRetry: () => retries++),
    );
    await tester.tap(find.byType(AppButton));
    expect(retries, 1);
  });
}

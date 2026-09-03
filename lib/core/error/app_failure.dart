/// The single error type the app speaks.
///
/// Every layer below the UI converts whatever it caught -- a socket exception,
/// a non-2xx response, a malformed payload -- into one of these, so screens
/// never branch on transport-level details.
///
/// This is a sealed hierarchy: a `switch` over an [AppFailure] that misses a
/// case is an analyzer error, not a silent fallthrough. Add a variant here and
/// the compiler points at every place that has to handle it.
///
/// The HTTP status mapping lives in the API client (#4). Deliberately absent is
/// any assumption about the shape of the backend's error body -- the Go service
/// does not exist yet, so [message] is populated only when a server-supplied
/// string is actually available.
sealed class AppFailure implements Exception {
  const AppFailure({this.message, this.cause, this.stackTrace});

  /// Server-supplied detail, when the backend sent one. Not for display unless
  /// the variant's [userMessage] says so -- backend copy is not UI copy.
  final String? message;

  /// The underlying exception, kept for logging. Never shown to a user.
  final Object? cause;

  final StackTrace? stackTrace;

  /// Non-technical copy safe to put in a toast.
  String get userMessage;

  /// Whether retrying the same request could plausibly succeed. Drives whether
  /// an error state offers a retry action.
  bool get isRetryable;

  @override
  String toString() => '$runtimeType(${message ?? userMessage})';
}

/// No usable connection: DNS failure, timeout, socket drop, airplane mode.
final class NetworkFailure extends AppFailure {
  const NetworkFailure({super.message, super.cause, super.stackTrace});

  @override
  String get userMessage => 'No connection. Check your network and try again.';

  @override
  bool get isRetryable => true;
}

/// The session is gone and could not be refreshed. The API client raises this
/// only after a refresh attempt has already failed; it forces a sign-out.
final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({super.message, super.cause, super.stackTrace});

  @override
  String get userMessage => 'Your session expired. Sign in again.';

  @override
  bool get isRetryable => false;
}

/// The request was well-formed but rejected on its contents -- a taken
/// username, a malformed friend code. [field] names the offending input when
/// the backend identifies one, so a form can mark it inline.
final class ValidationFailure extends AppFailure {
  const ValidationFailure({
    this.field,
    super.message,
    super.cause,
    super.stackTrace,
  });

  final String? field;

  /// Validation copy comes from the server when present: it is the only party
  /// that knows *why* the value was rejected.
  @override
  String get userMessage =>
      message ?? 'That does not look right. Check it and try again.';

  @override
  bool get isRetryable => false;
}

/// A product invariant was violated. The backend uses 409 for the rules in the
/// design doc: a player already has an active game, or the two users are not
/// friends. The server's own wording is the useful one here -- see the toast
/// copy in the UI spec ("You already have an active game. Finish it first.").
final class ConflictFailure extends AppFailure {
  const ConflictFailure({super.message, super.cause, super.stackTrace});

  @override
  String get userMessage => message ?? 'That is not possible right now.';

  @override
  bool get isRetryable => false;
}

/// The backend failed (5xx). [statusCode] is kept for logs.
final class ServerFailure extends AppFailure {
  const ServerFailure({
    this.statusCode,
    super.message,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;

  @override
  String get userMessage =>
      'Something went wrong on our end. Try again shortly.';

  @override
  bool get isRetryable => true;
}

/// Nothing else fits -- an unexpected exception or an unmapped status. Treated
/// as retryable because we cannot prove it is not.
final class UnknownFailure extends AppFailure {
  const UnknownFailure({super.message, super.cause, super.stackTrace});

  @override
  String get userMessage => 'Something went wrong. Try again.';

  @override
  bool get isRetryable => true;
}

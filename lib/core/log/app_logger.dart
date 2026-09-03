import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Severity, ordered. Anything below [AppLogger.minimumLevel] is dropped.
enum LogLevel {
  debug,
  info,
  warn,
  error;

  bool operator >=(LogLevel other) => index >= other.index;
}

/// A deliberately small logger.
///
/// Verbose in debug, near-silent in release: release builds emit errors only,
/// so a shipped app never streams user activity into the device console. There
/// is no file sink, no remote sink, and no PII scrubbing -- because nothing is
/// persisted, there is nothing to scrub. If crash reporting arrives later it
/// hooks in at [_emit] rather than at every call site.
class AppLogger {
  const AppLogger(this.name);

  /// Component name, shown as the log's source (e.g. `router`, `api`).
  final String name;

  /// Debug builds log everything; release builds log errors only.
  static const LogLevel minimumLevel = kDebugMode
      ? LogLevel.debug
      : LogLevel.error;

  void debug(String message) => _emit(LogLevel.debug, message);

  void info(String message) => _emit(LogLevel.info, message);

  void warn(String message, {Object? error}) =>
      _emit(LogLevel.warn, message, error: error);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void _emit(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!(level >= minimumLevel)) return;

    developer.log(
      message,
      name: name,
      // dart:developer levels follow package:logging: 500 fine, 800 info,
      // 900 warning, 1000 severe.
      level: switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warn => 900,
        LogLevel.error => 1000,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }
}

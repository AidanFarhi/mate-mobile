import 'package:flutter/material.dart';
import 'package:mate/core/error/app_failure.dart';

/// The app's only transient message.
///
/// A [SnackBar] under the hood, styled by `snackBarTheme` and stripped of its
/// action slot: the design's toast is a statement, never a choice. Anything the
/// user has to decide gets the confirmation sheet instead.
///
/// Each call replaces the toast on screen rather than queueing behind it. Three
/// failed moves in a row should say the last thing that happened, not spend
/// seven seconds replaying the first two.
class AppToast {
  const AppToast._();

  /// The design's dismiss timing.
  static const Duration duration = Duration(milliseconds: 2200);

  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: duration));
  }

  /// Shows [failure]'s user-facing copy.
  ///
  /// This is the only sanctioned way to put a failure in front of someone
  /// without a full [AppErrorState]: it guarantees `userMessage` is what gets
  /// shown, never `message`, which is backend copy and not UI copy.
  static void showFailure(BuildContext context, AppFailure failure) =>
      show(context, failure.userMessage);
}

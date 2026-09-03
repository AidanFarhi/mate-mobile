import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mate/app/app.dart';
import 'package:mate/features/auth/auth_controller.dart';

void main() {
  final ProviderContainer container = ProviderContainer();

  // Kick off session resolution before the first frame. It is intentionally not
  // awaited: the router parks on the splash while AuthStatus is `unknown` and
  // redirects itself once bootstrap settles.
  unawaited(container.read(authControllerProvider.notifier).bootstrap());

  runApp(
    UncontrolledProviderScope(container: container, child: const MateApp()),
  );
}

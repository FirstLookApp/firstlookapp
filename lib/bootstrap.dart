import 'dart:async';
import 'dart:ui';

import 'package:firstlook/app.dart';
import 'package:firstlook/core/errors/global_error_handler.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/storage/hive_service.dart';
import 'package:firstlook/services/environment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap() async {
  ProviderContainer? container;

  return runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await EnvironmentService.initialize();
      await HiveService.initialize();

      container = ProviderContainer(
        observers: <ProviderObserver>[
          AppProviderObserver(),
        ],
      );

      FlutterError.onError = (FlutterErrorDetails details) {
        GlobalErrorHandler.handleFlutterError(details, container!);
      };

      PlatformDispatcher.instance.onError =
          (Object error, StackTrace stackTrace) {
        GlobalErrorHandler.handlePlatformError(error, stackTrace, container!);
        return true;
      };

      runApp(
        UncontrolledProviderScope(
          container: container!,
          child: const FirstLookApp(),
        ),
      );
    },
    (Object error, StackTrace stackTrace) {
      final ProviderContainer? activeContainer = container;
      if (activeContainer == null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
          ),
        );
        return;
      }
      GlobalErrorHandler.handleZoneError(error, stackTrace, activeContainer);
    },
  )!;
}

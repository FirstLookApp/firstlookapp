import 'dart:async';

import 'package:firstlook/app.dart';
import 'package:firstlook/core/errors/global_error_handler.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/storage/hive_service.dart';
import 'package:firstlook/services/environment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvironmentService.initialize();
  await HiveService.initialize();

  final ProviderContainer container = ProviderContainer(
    observers: <ProviderObserver>[
      AppProviderObserver(),
    ],
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    GlobalErrorHandler.handleFlutterError(details, container);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    GlobalErrorHandler.handlePlatformError(error, stackTrace, container);
    return true;
  };

  runZonedGuarded(
    () => runApp(
      UncontrolledProviderScope(
        container: container,
        child: const FirstLookApp(),
      ),
    ),
    (Object error, StackTrace stackTrace) {
      GlobalErrorHandler.handleZoneError(error, stackTrace, container);
    },
  );
}

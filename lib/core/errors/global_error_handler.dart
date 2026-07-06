import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/services/environment_service.dart';
import 'package:firstlook/services/logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class GlobalErrorHandler {
  static void handleFlutterError(
    FlutterErrorDetails details,
    ProviderContainer container,
  ) {
    _log(
      container: container,
      message: details.exceptionAsString(),
      stackTrace: details.stack,
    );
  }

  static void handlePlatformError(
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _log(
      container: container,
      message: error.toString(),
      stackTrace: stackTrace,
    );
  }

  static void handleZoneError(
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _log(
      container: container,
      message: error.toString(),
      stackTrace: stackTrace,
    );
  }

  static void _log({
    required ProviderContainer container,
    required String message,
    StackTrace? stackTrace,
  }) {
    final LoggerService logger = container.read(loggerServiceProvider);
    logger.error(message, stackTrace: stackTrace);

    if (!EnvironmentService.instance.isProduction) {
      FlutterError.presentError(
        FlutterErrorDetails(
          exception: message,
          stack: stackTrace,
          library: 'FirstLook',
        ),
      );
    }
  }
}

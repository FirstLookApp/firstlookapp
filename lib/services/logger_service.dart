import 'package:firstlook/services/environment_service.dart';
import 'package:flutter/foundation.dart';

class LoggerService {
  void debug(String message) {
    if (!EnvironmentService.instance.isDebugLoggingEnabled) {
      return;
    }

    debugPrint('[DEBUG] $message');
  }

  void info(String message) {
    if (!EnvironmentService.instance.isDebugLoggingEnabled) {
      return;
    }

    debugPrint('[INFO] $message');
  }

  void error(String message, {StackTrace? stackTrace}) {
    debugPrint('[ERROR] $message');

    if (stackTrace != null && EnvironmentService.instance.isDebugLoggingEnabled) {
      debugPrint(stackTrace.toString());
    }
  }
}

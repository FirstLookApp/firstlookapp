import 'package:dio/dio.dart';
import 'package:firstlook/services/environment_service.dart';
import 'package:firstlook/services/logger_service.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);

  final LoggerService _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (EnvironmentService.instance.isDebugLoggingEnabled) {
      _logger.debug(
        'Request ${options.method} ${options.uri} query=${options.queryParameters}',
      );
    }

    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (EnvironmentService.instance.isDebugLoggingEnabled) {
      _logger.debug(
        'Response ${response.statusCode} ${response.requestOptions.uri}',
      );
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (EnvironmentService.instance.isDebugLoggingEnabled) {
      _logger.error(
        'Request failed ${err.requestOptions.uri} (${err.response?.statusCode})',
      );
    }

    handler.next(err);
  }
}

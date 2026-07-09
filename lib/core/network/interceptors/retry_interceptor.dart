import 'package:dio/dio.dart';
import 'package:firstlook/core/constants/app_constants.dart';
import 'package:retry/retry.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);

  final Dio _dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final bool shouldRetry = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;
    final bool alreadyRetriedNetwork =
        err.requestOptions.extra['hasRetriedNetwork'] as bool? ?? false;

    if (!shouldRetry || alreadyRetriedNetwork) {
      handler.next(err);
      return;
    }

    try {
      err.requestOptions.extra['hasRetriedNetwork'] = true;
      final Response<dynamic> response = await retry(
        () => _dio.fetch<dynamic>(err.requestOptions),
        maxAttempts: AppConstants.maxRetryAttempts,
      );
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }
}

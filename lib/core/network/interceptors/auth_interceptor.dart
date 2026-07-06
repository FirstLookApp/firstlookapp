import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firstlook/core/storage/secure_token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureTokenStorage tokenStorage,
    required Future<String?> Function() refreshAccessToken,
  })  : _tokenStorage = tokenStorage,
        _refreshAccessToken = refreshAccessToken;

  final SecureTokenStorage _tokenStorage;
  final Future<String?> Function() _refreshAccessToken;
  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bool requiresAuth = options.extra['requiresAuth'] as bool? ?? true;

    if (!requiresAuth) {
      handler.next(options);
      return;
    }

    final String? accessToken = await _tokenStorage.readAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final bool isUnauthorized = err.response?.statusCode == 401;
    final bool isRefreshCall =
        err.requestOptions.extra['isRefreshCall'] as bool? ?? false;
    final bool alreadyRetried =
        err.requestOptions.extra['hasRetried'] as bool? ?? false;

    if (!isUnauthorized || isRefreshCall || alreadyRetried) {
      handler.next(err);
      return;
    }

    try {
      if (_refreshCompleter == null) {
        _refreshCompleter = Completer<String?>();
        final String? newAccessToken = await _refreshAccessToken();
        _refreshCompleter!.complete(newAccessToken);
      }

      final String? token = await _refreshCompleter!.future;
      _refreshCompleter = null;

      if (token == null || token.isEmpty) {
        handler.next(err);
        return;
      }

      final RequestOptions requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $token';
      requestOptions.extra['hasRetried'] = true;

      final Response<dynamic> response =
          await Dio().fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } catch (_) {
      _refreshCompleter = null;
      handler.next(err);
    }
  }
}

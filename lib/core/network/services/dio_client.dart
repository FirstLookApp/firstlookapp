import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firstlook/core/network/interceptors/auth_interceptor.dart';
import 'package:firstlook/core/network/interceptors/logging_interceptor.dart';
import 'package:firstlook/core/network/interceptors/retry_interceptor.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/storage/secure_token_storage.dart';
import 'package:firstlook/features/auth/domain/repositories/auth_repository.dart';
import 'package:firstlook/services/certificate_pinning_service.dart';
import 'package:firstlook/services/environment_service.dart';
import 'package:firstlook/services/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DioClient {
  DioClient({
    required Ref ref,
    required EnvironmentService environmentService,
    required SecureTokenStorage tokenStorage,
    required LoggerService loggerService,
  })  : _ref = ref,
        _environmentService = environmentService,
        _tokenStorage = tokenStorage,
        _loggerService = loggerService,
        _instance = Dio() {
    _configure();
  }

  final Ref _ref;
  final EnvironmentService _environmentService;
  final SecureTokenStorage _tokenStorage;
  final LoggerService _loggerService;
  final Dio _instance;
  final CertificatePinningService _certificatePinningService =
      const CertificatePinningService();

  Dio get instance => _instance;

  void _configure() {
    _instance.options = BaseOptions(
      baseUrl: _environmentService.baseUrl,
      connectTimeout:
          Duration(milliseconds: _environmentService.connectTimeoutMs),
      receiveTimeout:
          Duration(milliseconds: _environmentService.receiveTimeoutMs),
      sendTimeout: Duration(milliseconds: _environmentService.sendTimeoutMs),
      headers: <String, dynamic>{
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    final HttpClientAdapter adapter = _instance.httpClientAdapter;
    if (adapter is IOHttpClientAdapter && _environmentService.isProduction) {
      adapter.createHttpClient = () {
        final HttpClient client = HttpClient();
        _certificatePinningService.configure(client);
        return client;
      };
    }

    _instance.interceptors.addAll(
      <Interceptor>[
        AuthInterceptor(
          tokenStorage: _tokenStorage,
          refreshAccessToken: _refreshAccessToken,
        ),
        RetryInterceptor(_instance),
        LoggingInterceptor(_loggerService),
      ],
    );
  }

  Future<String?> _refreshAccessToken() async {
    final AuthRepository repository = _ref.read(authRepositoryProvider);
    final String? refreshToken = await _tokenStorage.readRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final tokens = await repository.refreshToken();
    return tokens.accessToken;
  }
}

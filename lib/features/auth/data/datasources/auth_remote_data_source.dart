import 'package:dio/dio.dart';
import 'package:firstlook/features/auth/data/models/auth_response_model.dart';
import 'package:firstlook/features/auth/data/models/auth_tokens_model.dart';
import 'package:firstlook/features/auth/data/models/login_request_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: LoginRequestModel(email: email, password: password).toJson(),
      options: Options(
        extra: <String, dynamic>{
          'requiresAuth': false,
        },
      ),
    );

    return AuthResponseModel.fromJson(
      response.data ?? <String, dynamic>{},
      rememberMe: rememberMe,
    );
  }

  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: <String, dynamic>{
        'refreshToken': refreshToken,
      },
      options: Options(
        extra: <String, dynamic>{
          'requiresAuth': false,
          'isRefreshCall': true,
        },
      ),
    );

    return AuthTokensModel.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post<void>(
      '/auth/logout',
      data: <String, dynamic>{
        'refreshToken': refreshToken,
      },
    );
  }
}

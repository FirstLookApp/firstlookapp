import 'package:dio/dio.dart';
import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/network/api_paths.dart';
import 'package:firstlook/features/auth/data/models/auth_response_model.dart';
import 'package:firstlook/features/auth/data/models/auth_tokens_model.dart';
import 'package:firstlook/features/auth/data/models/login_request_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  Future<AuthResponseModel> login({
    required String login,
    required String password,
    required bool rememberMe,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      ApiPaths.login,
      data: LoginRequestModel(login: login, password: password).toJson(),
      options: Options(
        extra: <String, dynamic>{
          'requiresAuth': false,
        },
      ),
    );

    final ApiEnvelope<AuthResponseModel> envelope =
        ApiEnvelope<AuthResponseModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => AuthResponseModel.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
        rememberMe: rememberMe,
      ),
    );

    return envelope.data;
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String biography,
    required String email,
    required String password,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      ApiPaths.register,
      data: <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'biography': biography,
        'email': email,
        'password': password,
      },
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );
  }

  Future<AuthResponseModel> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      ApiPaths.verifyEmail,
      data: <String, dynamic>{
        'email': email,
        'otp': otp,
      },
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );

    final ApiEnvelope<AuthResponseModel> envelope =
        ApiEnvelope<AuthResponseModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => AuthResponseModel.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
        rememberMe: true,
      ),
    );

    return envelope.data;
  }

  Future<void> resendOtp({
    required String email,
    required int purpose,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      ApiPaths.resendOtp,
      data: <String, dynamic>{
        'email': email,
        'purpose': purpose,
      },
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post<Map<String, dynamic>>(
      ApiPaths.forgotPassword,
      data: <String, dynamic>{'email': email},
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      ApiPaths.resetPassword,
      data: <String, dynamic>{
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      },
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );
  }

  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      ApiPaths.refreshToken,
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

    final ApiEnvelope<AuthResponseModel> envelope =
        ApiEnvelope<AuthResponseModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => AuthResponseModel.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
        rememberMe: true,
      ),
    );

    return AuthTokensModel(
      accessToken: envelope.data.tokens.accessToken,
      refreshToken: envelope.data.tokens.refreshToken,
    );
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post<Map<String, dynamic>>(
      ApiPaths.logout,
      data: <String, dynamic>{'refreshToken': refreshToken},
    );
  }
}

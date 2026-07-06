import 'package:firstlook/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:firstlook/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:firstlook/features/auth/domain/entities/auth_tokens.dart';
import 'package:firstlook/features/auth/domain/entities/user_session.dart';
import 'package:firstlook/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<UserSession> login({
    required String login,
    required String password,
    required bool rememberMe,
  }) async {
    final UserSession response = await _remoteDataSource.login(
      login: login,
      password: password,
      rememberMe: rememberMe,
    );

    await _localDataSource.persistSession(response);
    return response;
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String biography,
    required String email,
    required String password,
  }) {
    return _remoteDataSource.register(
      firstName: firstName,
      lastName: lastName,
      username: username,
      biography: biography,
      email: email,
      password: password,
    );
  }

  @override
  Future<UserSession> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final UserSession response = await _remoteDataSource.verifyEmail(
      email: email,
      otp: otp,
    );
    await _localDataSource.persistSession(response);
    return response;
  }

  @override
  Future<void> resendEmailVerificationOtp(String email) {
    return _remoteDataSource.resendOtp(
      email: email,
      purpose: 1,
    );
  }

  @override
  Future<void> forgotPassword(String email) {
    return _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return _remoteDataSource.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> logout() async {
    final UserSession? currentSession = await _localDataSource.restoreSession();
    final String refreshToken = currentSession?.tokens.refreshToken ?? '';

    if (refreshToken.isNotEmpty) {
      await _remoteDataSource.logout(refreshToken);
    }

    await _localDataSource.clear();
  }

  @override
  Future<AuthTokens> refreshToken() async {
    final UserSession? currentSession = await _localDataSource.restoreSession();
    final String refreshToken = currentSession?.tokens.refreshToken ?? '';
    final AuthTokens response =
        await _remoteDataSource.refreshToken(refreshToken);

    if (currentSession != null) {
      await _localDataSource.persistSession(
        UserSession(
          email: currentSession.email,
          username: currentSession.username,
          rememberMe: currentSession.rememberMe,
          tokens: response,
        ),
      );
    }

    return response;
  }

  @override
  Future<UserSession?> restoreSession() {
    return _localDataSource.restoreSession();
  }
}

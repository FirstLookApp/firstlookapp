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
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final UserSession response = await _remoteDataSource.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    await _localDataSource.persistSession(response);
    return response;
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
    final AuthTokens response = await _remoteDataSource.refreshToken(refreshToken);

    if (currentSession != null) {
      await _localDataSource.persistSession(
        UserSession(
          email: currentSession.email,
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

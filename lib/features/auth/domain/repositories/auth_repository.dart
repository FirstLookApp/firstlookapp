import 'package:firstlook/features/auth/domain/entities/auth_tokens.dart';
import 'package:firstlook/features/auth/domain/entities/user_session.dart';

abstract class AuthRepository {
  Future<UserSession?> restoreSession();

  Future<UserSession> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<AuthTokens> refreshToken();

  Future<void> logout();
}

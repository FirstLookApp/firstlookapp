import 'package:firstlook/features/auth/domain/entities/auth_tokens.dart';
import 'package:firstlook/features/auth/domain/entities/user_session.dart';

abstract class AuthRepository {
  Future<UserSession?> restoreSession();

  Future<UserSession> login({
    required String login,
    required String password,
    required bool rememberMe,
  });

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String biography,
    required String email,
    required String password,
  });

  Future<UserSession> verifyEmail({
    required String email,
    required String otp,
  });

  Future<void> resendEmailVerificationOtp(String email);

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<AuthTokens> refreshToken();

  Future<void> logout();
}

import 'package:firstlook/features/auth/data/models/auth_tokens_model.dart';
import 'package:firstlook/features/auth/domain/entities/user_session.dart';

class AuthResponseModel extends UserSession {
  const AuthResponseModel({
    required super.email,
    required super.username,
    required super.rememberMe,
    required AuthTokensModel super.tokens,
  });

  factory AuthResponseModel.fromJson(
    Map<String, dynamic> json, {
    required bool rememberMe,
  }) {
    return AuthResponseModel(
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      rememberMe: rememberMe,
      tokens: AuthTokensModel.fromJson(
        json['tokens'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}

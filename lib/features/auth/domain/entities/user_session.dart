import 'package:firstlook/features/auth/domain/entities/auth_tokens.dart';

class UserSession {
  const UserSession({
    required this.email,
    required this.username,
    required this.rememberMe,
    required this.tokens,
  });

  final String email;
  final String username;
  final bool rememberMe;
  final AuthTokens tokens;
}

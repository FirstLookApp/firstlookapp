import 'package:firstlook/core/storage/hive_service.dart';
import 'package:firstlook/core/storage/local_storage_keys.dart';
import 'package:firstlook/core/storage/secure_token_storage.dart';
import 'package:firstlook/features/auth/data/models/auth_tokens_model.dart';
import 'package:firstlook/features/auth/domain/entities/user_session.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource({
    required SecureTokenStorage tokenStorage,
  }) : _tokenStorage = tokenStorage;

  final SecureTokenStorage _tokenStorage;

  Future<void> persistSession(UserSession session) async {
    await _tokenStorage.saveAccessToken(session.tokens.accessToken);
    await _tokenStorage.saveRefreshToken(session.tokens.refreshToken);
    await HiveService.authBox.put(LocalStorageKeys.authRememberMe, session.rememberMe);
    await HiveService.authBox.put(LocalStorageKeys.authEmail, session.email);
  }

  Future<UserSession?> restoreSession() async {
    final String? accessToken = await _tokenStorage.readAccessToken();
    final String? refreshToken = await _tokenStorage.readRefreshToken();
    final bool rememberMe =
        HiveService.authBox.get(LocalStorageKeys.authRememberMe, defaultValue: false)
            as bool;
    final String email =
        HiveService.authBox.get(LocalStorageKeys.authEmail, defaultValue: '') as String;

    if (accessToken == null || refreshToken == null || accessToken.isEmpty) {
      return null;
    }

    return UserSession(
      email: email,
      rememberMe: rememberMe,
      tokens: AuthTokensModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );
  }

  Future<void> clear() async {
    await _tokenStorage.clear();
    await HiveService.authBox.delete(LocalStorageKeys.authRememberMe);
    await HiveService.authBox.delete(LocalStorageKeys.authEmail);
  }
}

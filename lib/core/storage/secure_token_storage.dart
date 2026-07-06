import 'package:firstlook/core/storage/local_storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  const SecureTokenStorage();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> saveAccessToken(String token) {
    return _storage.write(key: LocalStorageKeys.accessToken, value: token);
  }

  Future<void> saveRefreshToken(String token) {
    return _storage.write(key: LocalStorageKeys.refreshToken, value: token);
  }

  Future<String?> readAccessToken() {
    return _storage.read(key: LocalStorageKeys.accessToken);
  }

  Future<String?> readRefreshToken() {
    return _storage.read(key: LocalStorageKeys.refreshToken);
  }

  Future<void> clear() {
    return _storage.deleteAll();
  }
}

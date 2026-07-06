import 'package:firstlook/features/auth/domain/entities/auth_tokens.dart';
import 'package:firstlook/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  const RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthTokens> call() {
    return _repository.refreshToken();
  }
}

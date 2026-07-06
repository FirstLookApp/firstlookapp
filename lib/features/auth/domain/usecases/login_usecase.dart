import 'package:firstlook/features/auth/domain/entities/user_session.dart';
import 'package:firstlook/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserSession> call({
    required String login,
    required String password,
    required bool rememberMe,
  }) {
    return _repository.login(
      login: login,
      password: password,
      rememberMe: rememberMe,
    );
  }
}

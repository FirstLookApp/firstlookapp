import 'package:firstlook/core/network/parsers/api_error_parser.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/auth/domain/entities/user_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.session,
  });

  final AuthStatus status;
  final UserSession? session;

  AuthState copyWith({
    AuthStatus? status,
    UserSession? session,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
    );
  }
}

class AuthController extends AsyncNotifier<AuthState> {
  final ApiErrorParser _errorParser = const ApiErrorParser();

  @override
  Future<AuthState> build() async {
    final repository = ref.read(authRepositoryProvider);
    final UserSession? session = await repository.restoreSession();

    if (session == null) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }

    return AuthState(
      status: AuthStatus.authenticated,
      session: session,
    );
  }

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = const AsyncLoading<AuthState>();
    state = await _guardAuthState(() async {
      final repository = ref.read(authRepositoryProvider);
      final UserSession session = await repository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      return AuthState(
        status: AuthStatus.authenticated,
        session: session,
      );
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading<AuthState>();
    state = await _guardAuthState(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      return const AuthState(status: AuthStatus.unauthenticated);
    });
  }

  Future<AsyncValue<AuthState>> _guardAuthState(
    Future<AuthState> Function() action,
  ) async {
    try {
      final AuthState result = await action();
      return AsyncData<AuthState>(result);
    } catch (error, stackTrace) {
      return AsyncError<AuthState>(_errorParser.parse(error), stackTrace);
    }
  }
}

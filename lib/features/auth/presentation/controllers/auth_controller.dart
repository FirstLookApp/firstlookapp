import 'package:firstlook/core/network/parsers/api_error_parser.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/auth/domain/entities/user_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  otpRequired,
  passwordResetOtpSent,
}

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.pendingEmail,
  });

  final AuthStatus status;
  final UserSession? session;
  final String? pendingEmail;

  AuthState copyWith({
    AuthStatus? status,
    UserSession? session,
    String? pendingEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      pendingEmail: pendingEmail ?? this.pendingEmail,
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
    required String login,
    required String password,
    required bool rememberMe,
  }) async {
    state = const AsyncLoading<AuthState>();
    state = await _guardAuthState(() async {
      final repository = ref.read(authRepositoryProvider);
      final UserSession session = await repository.login(
        login: login,
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

  Future<void> handleUnauthorized() async {
    final repository = ref.read(authRepositoryProvider);

    try {
      await repository.clearSession();
    } catch (_) {
      // Best effort: local session cleanup is handled by the repository.
    }

    state = const AsyncData<AuthState>(
      AuthState(status: AuthStatus.unauthenticated),
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String biography,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading<AuthState>();
    state = await _guardAuthState(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.register(
        firstName: firstName,
        lastName: lastName,
        username: username,
        biography: biography,
        email: email,
        password: password,
      );
      return AuthState(
        status: AuthStatus.otpRequired,
        pendingEmail: email,
      );
    });
  }

  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {
    state = const AsyncLoading<AuthState>();
    state = await _guardAuthState(() async {
      final repository = ref.read(authRepositoryProvider);
      final UserSession session = await repository.verifyEmail(
        email: email,
        otp: otp,
      );
      return AuthState(
        status: AuthStatus.authenticated,
        session: session,
      );
    });
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncLoading<AuthState>();
    state = await _guardAuthState(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.forgotPassword(email);
      return const AuthState(status: AuthStatus.passwordResetOtpSent);
    });
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = const AsyncLoading<AuthState>();
    state = await _guardAuthState(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
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

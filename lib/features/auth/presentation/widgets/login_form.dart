import 'package:firstlook/core/errors/app_exception.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_header.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<AuthState> authState = ref.watch(authControllerProvider);
    final Object? error = authState.asError?.error;
    final String? errorMessage = error is AppException ? error.message : null;

    ref.listen<AsyncValue<AuthState>>(authControllerProvider,
        (_, AsyncValue<AuthState> next) {
      if (next.valueOrNull?.status == AuthStatus.authenticated) {
        context.go(RouteNames.discoverPath);
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const AuthHeader(),
        const SizedBox(height: 30),
        Text(
          l10n.authDiscoverTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.authDiscoverSubtitle,
          style: const TextStyle(
            color: Color(0xFF7C7C84),
            fontSize: 12,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 34),
        AuthTextField(
          controller: _emailController,
          label: l10n.authEmailAddressLabel,
          hint: l10n.loginEmailHint,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _passwordController,
          label: l10n.authPasswordLabel,
          hint: l10n.loginPasswordHint,
          obscureText: true,
        ),
        const SizedBox(height: 42),
        AuthPrimaryButton(
          label: l10n.authRegisterCta,
          outlined: true,
          onPressed: () => context.go(RouteNames.registerPath),
        ),
        const SizedBox(height: 14),
        AuthPrimaryButton(
          label: l10n.authLoginCta,
          isLoading: authState.isLoading,
          onPressed: () {
            ref.read(authControllerProvider.notifier).login(
                  login: _emailController.text.trim(),
                  password: _passwordController.text,
                  rememberMe: true,
                );
          },
        ),
        if (authState.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              errorMessage ?? l10n.commonUnexpectedError,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

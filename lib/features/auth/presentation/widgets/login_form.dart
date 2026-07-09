import 'package:firstlook/core/errors/app_exception.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/firstlook_app_icon.dart';
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

    ref.listen<AsyncValue<AuthState>>(authControllerProvider, (
      _,
      AsyncValue<AuthState> next,
    ) {
      if (next.valueOrNull?.status == AuthStatus.authenticated) {
        context.go(RouteNames.discoverPath);
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 30),
        const Center(child: FirstLookAppIcon(size: 106)),
        const SizedBox(height: 46),
        Text(
          l10n.authDiscoverTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.secondary,
                fontSize: 26,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.authDiscoverSubtitle,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 30),
        AuthTextField(
          controller: _emailController,
          label: l10n.loginIdentifierLabel,
          hint: l10n.loginIdentifierHint,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _passwordController,
          label: l10n.authPasswordLabel,
          hint: l10n.loginPasswordHint,
          obscureText: true,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go(RouteNames.forgotPasswordPath),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            child: Text(l10n.forgotPasswordTitle),
          ),
        ),
        const SizedBox(height: 24),
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
        const SizedBox(height: 14),
        AuthPrimaryButton(
          label: l10n.authRegisterCta,
          outlined: true,
          onPressed: () => context.go(RouteNames.registerPath),
        ),
        if (authState.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              errorMessage ?? l10n.commonUnexpectedError,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/errors/app_exception.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/widgets/app_button.dart';
import 'package:firstlook/widgets/app_card.dart';
import 'package:firstlook/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = true;

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
    final String? errorMessage =
        error is AppException ? error.message : null;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.loginTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.loginSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: _emailController,
            label: l10n.loginEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _passwordController,
            label: l10n.loginPassword,
            obscureText: true,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _rememberMe,
            title: Text(l10n.loginRememberMe),
            onChanged: (bool? value) {
              setState(() {
                _rememberMe = value ?? true;
              });
            },
          ),
          AppButton(
            label: l10n.loginButton,
            isLoading: authState.isLoading,
            onPressed: () {
              ref.read(authControllerProvider.notifier).login(
                    email: _emailController.text.trim(),
                    password: _passwordController.text,
                    rememberMe: _rememberMe,
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
      ),
    );
  }
}

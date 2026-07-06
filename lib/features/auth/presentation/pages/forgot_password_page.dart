import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_button.dart';
import 'package:firstlook/widgets/app_text_field.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _codeSent = false;

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<AuthState> authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<AuthState>>(authControllerProvider,
        (_, AsyncValue<AuthState> next) {
      if (next.valueOrNull?.status == AuthStatus.passwordResetOtpSent) {
        setState(() => _codeSent = true);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.large),
          children: <Widget>[
            const FirstLookLogo(),
            const SizedBox(height: 48),
            Text(l10n.forgotPasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(l10n.forgotPasswordSubtitle),
            const SizedBox(height: 24),
            AppTextField(
                controller: _email,
                label: l10n.authEmail,
                keyboardType: TextInputType.emailAddress),
            if (_codeSent) ...<Widget>[
              const SizedBox(height: 12),
              AppTextField(
                  controller: _otp,
                  label: l10n.authOtp,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              AppTextField(
                  controller: _password,
                  label: l10n.authNewPassword,
                  obscureText: true),
            ],
            const SizedBox(height: 20),
            AppButton(
              label: _codeSent
                  ? l10n.resetPasswordButton
                  : l10n.forgotPasswordButton,
              isLoading: authState.isLoading,
              onPressed: () {
                if (_codeSent) {
                  ref.read(authControllerProvider.notifier).resetPassword(
                        email: _email.text.trim(),
                        otp: _otp.text.trim(),
                        newPassword: _password.text,
                      );
                  context.go(RouteNames.loginPath);
                  return;
                }
                ref
                    .read(authControllerProvider.notifier)
                    .forgotPassword(_email.text.trim());
              },
            ),
          ],
        ),
      ),
    );
  }
}

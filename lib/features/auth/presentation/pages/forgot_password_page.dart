import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_header.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_spacing.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                18,
                AppSpacing.large,
                AppSpacing.large,
              ),
              children: <Widget>[
                const AuthHeader(),
                const SizedBox(height: 46),
                Text(
                  l10n.forgotPasswordTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.forgotPasswordSubtitle,
                  style: const TextStyle(
                    color: Color(0xFF7C7C84),
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 34),
                AuthTextField(
                  controller: _email,
                  label: l10n.authEmailAddressLabel,
                  hint: l10n.loginEmailHint,
                  keyboardType: TextInputType.emailAddress,
                ),
                if (_codeSent) ...<Widget>[
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _otp,
                    label: l10n.authOtpLabel,
                    hint: l10n.authOtpHint,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _password,
                    label: l10n.authNewPasswordLabel,
                    hint: l10n.loginPasswordHint,
                    obscureText: true,
                  ),
                ],
                const SizedBox(height: 42),
                AuthPrimaryButton(
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
        ),
      ),
    );
  }
}

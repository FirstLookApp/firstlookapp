import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_header.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/firstlook_app_icon.dart';
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
  final TextEditingController _passwordConfirmation = TextEditingController();
  bool _codeSent = false;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<AuthState> authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<AuthState>>(authControllerProvider, (
      _,
      AsyncValue<AuthState> next,
    ) {
      if (next.valueOrNull?.status == AuthStatus.passwordResetOtpSent) {
        setState(() => _codeSent = true);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _goBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
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
                  AuthHeader(onBack: _goBack),
                  const SizedBox(height: 28),
                  const Center(child: FirstLookAppIcon(size: 96)),
                  const SizedBox(height: 28),
                  Text(
                    l10n.forgotPasswordTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary(context),
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
                  if (!_codeSent)
                    AuthTextField(
                      controller: _email,
                      label: l10n.authEmailAddressLabel,
                      hint: l10n.loginEmailHint,
                      keyboardType: TextInputType.emailAddress,
                    )
                  else ...<Widget>[
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
                      onChanged: (_) => _clearPasswordError(),
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: _passwordConfirmation,
                      label: l10n.authPasswordConfirmationLabel,
                      hint: l10n.registerConfirmPasswordHint,
                      obscureText: true,
                      errorText: _passwordError,
                      onChanged: (_) => _clearPasswordError(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: _codeSent
                        ? l10n.resetPasswordButton
                        : l10n.forgotPasswordButton,
                    isLoading: authState.isLoading,
                    onPressed: () async {
                      if (_codeSent) {
                        if (_password.text != _passwordConfirmation.text) {
                          setState(
                            () => _passwordError = l10n.authPasswordMismatch,
                          );
                          return;
                        }

                        await ref
                            .read(authControllerProvider.notifier)
                            .resetPassword(
                              email: _email.text.trim(),
                              otp: _otp.text.trim(),
                              newPassword: _password.text,
                            );
                        if (!context.mounted) {
                          return;
                        }

                        final AuthStatus? status = ref
                            .read(authControllerProvider)
                            .valueOrNull
                            ?.status;
                        if (status == AuthStatus.unauthenticated) {
                          context.go(RouteNames.loginPath);
                        }
                        return;
                      }
                      await ref
                          .read(authControllerProvider.notifier)
                          .forgotPassword(_email.text.trim());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(RouteNames.loginPath);
  }

  void _clearPasswordError() {
    if (_passwordError == null) {
      return;
    }

    setState(() => _passwordError = null);
  }
}

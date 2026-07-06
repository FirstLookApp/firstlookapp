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

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({
    required this.email,
    super.key,
  });

  final String email;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final TextEditingController _otp = TextEditingController();

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<AuthState> authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<AuthState>>(authControllerProvider,
        (_, AsyncValue<AuthState> next) {
      if (next.valueOrNull?.status == AuthStatus.authenticated) {
        context.go(RouteNames.discoverPath);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const FirstLookLogo(),
              const SizedBox(height: 48),
              Text(l10n.otpTitle,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(l10n.otpSubtitle),
              const SizedBox(height: 24),
              AppTextField(
                  controller: _otp,
                  label: l10n.authOtp,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              AppButton(
                label: l10n.otpButton,
                isLoading: authState.isLoading,
                onPressed: () {
                  ref.read(authControllerProvider.notifier).verifyEmail(
                        email: widget.email,
                        otp: _otp.text.trim(),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_button.dart';
import 'package:firstlook/widgets/app_text_field.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _biography = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _biography.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<AuthState> authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<AuthState>>(authControllerProvider,
        (_, AsyncValue<AuthState> next) {
      if (next.valueOrNull?.status == AuthStatus.otpRequired) {
        context.go(
            '${RouteNames.otpPath}?email=${Uri.encodeComponent(_email.text.trim())}');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.large),
          children: <Widget>[
            const FirstLookLogo(),
            const SizedBox(height: 28),
            Text(l10n.registerTitle,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(l10n.registerSubtitle),
            const SizedBox(height: 24),
            AppTextField(controller: _firstName, label: l10n.authFirstName),
            const SizedBox(height: 12),
            AppTextField(controller: _lastName, label: l10n.authLastName),
            const SizedBox(height: 12),
            AppTextField(controller: _username, label: l10n.authUsername),
            const SizedBox(height: 12),
            AppTextField(
                controller: _biography, label: l10n.authBiography, maxLines: 2),
            const SizedBox(height: 12),
            AppTextField(
                controller: _email,
                label: l10n.authEmail,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            AppTextField(
                controller: _password,
                label: l10n.authPassword,
                obscureText: true),
            const SizedBox(height: 20),
            AppButton(
              label: l10n.registerButton,
              isLoading: authState.isLoading,
              onPressed: () {
                ref.read(authControllerProvider.notifier).register(
                      firstName: _firstName.text.trim(),
                      lastName: _lastName.text.trim(),
                      username: _username.text.trim(),
                      biography: _biography.text.trim(),
                      email: _email.text.trim(),
                      password: _password.text,
                    );
              },
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.loginPath),
              child: Text(l10n.goToLogin),
            ),
          ],
        ),
      ),
    );
  }
}

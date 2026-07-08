import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/firstlook_app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirmation = TextEditingController();
  String? _formError;

  bool get _passwordsDoNotMatch {
    return _passwordConfirmation.text.isNotEmpty &&
        _password.text != _passwordConfirmation.text;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
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
                const SizedBox(height: 30),
                const Center(child: FirstLookAppIcon(size: 104)),
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
                  controller: _fullName,
                  label: l10n.authFullNameLabel,
                  hint: l10n.registerNameHint,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _email,
                  label: l10n.authEmailAddressLabel,
                  hint: l10n.loginEmailHint,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _password,
                  label: l10n.authPasswordLabel,
                  hint: l10n.loginPasswordHint,
                  obscureText: true,
                  onChanged: (_) => setState(() => _formError = null),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _passwordConfirmation,
                  label: l10n.authPasswordConfirmationLabel,
                  hint: l10n.registerConfirmPasswordHint,
                  obscureText: true,
                  errorText:
                      _passwordsDoNotMatch ? l10n.authPasswordMismatch : null,
                  onChanged: (_) => setState(() => _formError = null),
                ),
                const SizedBox(height: 42),
                AuthPrimaryButton(
                  label: l10n.authRegisterCta,
                  isLoading: authState.isLoading,
                  onPressed: () => _submit(context, l10n),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => context.go(RouteNames.loginPath),
                  child: Text(
                    l10n.goToLogin,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_formError != null || authState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _formError ?? l10n.commonUnexpectedError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final String fullName = _fullName.text.trim();
    final String email = _email.text.trim();
    final String password = _password.text;

    if (fullName.isEmpty) {
      setState(() => _formError = l10n.authFullNameRequired);
      return;
    }

    if (_passwordsDoNotMatch || password != _passwordConfirmation.text) {
      setState(() => _formError = l10n.authPasswordMismatch);
      return;
    }

    final List<String> nameParts = fullName.split(RegExp(r'\s+'));
    final String firstName = nameParts.first;
    final String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : firstName;
    final String username = _usernameFromEmail(email);

    setState(() => _formError = null);
    await ref.read(authControllerProvider.notifier).register(
          firstName: firstName,
          lastName: lastName,
          username: username,
          biography: '',
          email: email,
          password: password,
        );

    final AuthStatus? status =
        ref.read(authControllerProvider).valueOrNull?.status;
    if (context.mounted && status == AuthStatus.otpRequired) {
      context.go('${RouteNames.otpPath}?email=${Uri.encodeComponent(email)}');
    }
  }

  String _usernameFromEmail(String email) {
    final String localPart = email.split('@').first;
    final String sanitized =
        localPart.toLowerCase().replaceAll(RegExp('[^a-z0-9_]'), '').trim();
    if (sanitized.length >= 3) {
      return sanitized;
    }
    return 'firstlook${DateTime.now().millisecondsSinceEpoch}';
  }
}

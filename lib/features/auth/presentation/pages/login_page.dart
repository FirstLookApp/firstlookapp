import 'package:firstlook/features/auth/presentation/widgets/login_form.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: const LoginForm(),
            ),
          ),
        ),
      ),
    );
  }
}

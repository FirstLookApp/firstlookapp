import 'package:firstlook/features/auth/presentation/widgets/login_form.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.large,
                18,
                AppSpacing.large,
                AppSpacing.large,
              ),
              child: LoginForm(),
            ),
          ),
        ),
      ),
    );
  }
}

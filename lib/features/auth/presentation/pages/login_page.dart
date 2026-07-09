import 'package:firstlook/features/auth/presentation/widgets/login_form.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 390,
                    minHeight: constraints.maxHeight,
                  ),
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
            );
          },
        ),
      ),
    );
  }
}

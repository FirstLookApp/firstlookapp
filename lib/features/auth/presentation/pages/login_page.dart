import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/auth/presentation/widgets/login_form.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
            Positioned(
              top: 4,
              left: 6,
              child: IconButton(
                tooltip: l10n.commonBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                    return;
                  }

                  context.go(RouteNames.discoverPath);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

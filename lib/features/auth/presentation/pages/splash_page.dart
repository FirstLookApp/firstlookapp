import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/firstlook_app_icon.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const FirstLookAppIcon(size: 104),
            const SizedBox(height: 18),
            const FirstLookLogo(size: 30),
            const SizedBox(height: 10),
            Text(
              l10n.splashTagline,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

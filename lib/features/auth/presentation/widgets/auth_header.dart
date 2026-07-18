import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          const Center(child: FirstLookLogo(size: 32)),
          Align(
            alignment: Alignment.centerLeft,
            child: onBack == null
                ? const Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.primary,
                    size: 18,
                  )
                : IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary(context),
                      size: 18,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

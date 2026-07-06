import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Icon(
          Icons.grid_view_rounded,
          color: AppColors.primary,
          size: 18,
        ),
        FirstLookLogo(size: 32),
      ],
    );
  }
}

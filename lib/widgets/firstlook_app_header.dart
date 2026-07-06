import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';

class FirstLookAppHeader extends StatelessWidget {
  const FirstLookAppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Icon(
          Icons.grid_view_rounded,
          color: AppColors.primary,
          size: 18,
        ),
        const FirstLookLogo(size: 30),
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ],
    );
  }
}

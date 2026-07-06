import 'package:firstlook/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FirstLookLogo extends StatelessWidget {
  const FirstLookLogo({
    this.size = 18,
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      'FirstLook',
      style: TextStyle(
        color: AppColors.primary,
        fontSize: size,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w900,
              height: 0.9,
              letterSpacing: 0,
            ),
            children: const <TextSpan>[
              TextSpan(
                text: 'First',
                style: TextStyle(color: AppColors.primary),
              ),
              TextSpan(
                text: 'look',
                style: TextStyle(color: AppColors.secondary),
              ),
            ],
          ),
        ),
        Text(
          'AppDiscovery',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: size * 0.18,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
  }
}

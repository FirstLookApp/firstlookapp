import 'package:flutter/material.dart';

class FirstLookLogo extends StatelessWidget {
  const FirstLookLogo({
    this.size = 18,
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/firstlook-logo.png',
      height: size * 1.18,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

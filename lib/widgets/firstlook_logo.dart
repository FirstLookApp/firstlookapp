import 'package:flutter/material.dart';

class FirstLookLogo extends StatelessWidget {
  const FirstLookLogo({
    this.size = 18,
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Image.asset(
      'assets/images/firstlook-logo.png',
      height: size * 1.18,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      color: isDark ? const Color(0x52FFFFFF) : null,
      colorBlendMode: isDark ? BlendMode.srcATop : null,
    );
  }
}

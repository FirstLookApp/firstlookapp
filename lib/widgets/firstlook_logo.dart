import 'package:flutter/material.dart';

class FirstLookLogo extends StatelessWidget {
  const FirstLookLogo({
    this.size = 18,
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget logo = Image.asset(
      'assets/images/firstlook-logo.png',
      height: size * 1.18,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (Theme.of(context).brightness == Brightness.light) {
      return logo;
    }

    return ColorFiltered(
      colorFilter: const ColorFilter.mode(
        Color(0x52FFFFFF),
        BlendMode.screen,
      ),
      child: logo,
    );
  }
}

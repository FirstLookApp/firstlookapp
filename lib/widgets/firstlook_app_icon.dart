import 'package:flutter/material.dart';

class FirstLookAppIcon extends StatelessWidget {
  const FirstLookAppIcon({
    this.size = 104,
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/icons/app-icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

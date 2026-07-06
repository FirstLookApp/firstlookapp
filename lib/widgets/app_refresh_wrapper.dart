import 'package:flutter/material.dart';

class AppRefreshWrapper extends StatelessWidget {
  const AppRefreshWrapper({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  final RefreshCallback onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}

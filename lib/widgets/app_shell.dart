import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          height: 64,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primarySoft,
          selectedIndex: navigationShell.currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (int index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: <Widget>[
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined, size: 20),
              selectedIcon: const Icon(Icons.explore, size: 20),
              label: l10n.navDiscover,
            ),
            NavigationDestination(
              icon: const Icon(Icons.article_outlined, size: 20),
              selectedIcon: const Icon(Icons.article, size: 20),
              label: l10n.navSubmit,
            ),
            NavigationDestination(
              icon: const Icon(Icons.star_border_rounded, size: 20),
              selectedIcon: const Icon(Icons.star_rounded, size: 20),
              label: l10n.navFavorites,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline, size: 20),
              selectedIcon: const Icon(Icons.person, size: 20),
              label: l10n.navProfile,
            ),
          ],
          labelTextStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

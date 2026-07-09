import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/showcase_coming_soon_dialog.dart';
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
      bottomNavigationBar: _FirstLookBottomNav(
        currentIndex: navigationShell.currentIndex,
        items: <_BottomNavItem>[
          _BottomNavItem(
            label: l10n.navDiscover,
            icon: Icons.local_fire_department_outlined,
          ),
          _BottomNavItem(
            label: l10n.navLeaderboard,
            icon: Icons.leaderboard_outlined,
          ),
          _BottomNavItem(
            label: l10n.navShowcase,
            icon: Icons.article_rounded,
            isShowcase: true,
          ),
          _BottomNavItem(
            label: l10n.navSubmit,
            icon: Icons.add_circle_outline_rounded,
          ),
          _BottomNavItem(
            label: l10n.navProfile,
            icon: Icons.person_outline_rounded,
          ),
        ],
        onTap: (int index) {
          if (index == 2) {
            showShowcaseComingSoonDialog(context);
            return;
          }

          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _FirstLookBottomNav extends StatelessWidget {
  const _FirstLookBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<_BottomNavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: items
                .asMap()
                .entries
                .map((MapEntry<int, _BottomNavItem> entry) {
              final int index = entry.key;
              final _BottomNavItem item = entry.value;

              return Expanded(
                child: _BottomNavButton(
                  item: item,
                  isSelected: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color contentColor =
        item.isShowcase ? AppColors.primary : AppColors.textSoft;

    return Semantics(
      selected: isSelected,
      button: true,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (item.isShowcase)
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: 19,
                  ),
                )
              else
                Icon(
                  item.icon,
                  color: contentColor,
                  size: 20,
                ),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 9,
                  fontWeight:
                      item.isShowcase ? FontWeight.w900 : FontWeight.w700,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    this.isShowcase = false,
  });

  final String label;
  final IconData icon;
  final bool isShowcase;
}

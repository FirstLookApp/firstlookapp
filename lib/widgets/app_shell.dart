import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/core/feedback/app_feedback_service.dart';
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
      backgroundColor: AppColors.background(context),
      body: ColoredBox(
        color: AppColors.background(context),
        child: navigationShell,
      ),
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
          AppFeedbackService.selection();
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
    final int effectiveCount = items.where((_) => true).length;
    final double slotWidth = MediaQuery.sizeOf(context).width / effectiveCount;
    final double indicatorWidth = slotWidth - 22;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(color: AppColors.outline(context)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Stack(
            children: <Widget>[
              if (currentIndex != 2)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  left: (slotWidth * currentIndex) +
                      ((slotWidth - indicatorWidth) / 2),
                  top: 8,
                  child: IgnorePointer(
                    child: _BottomNavGlow(
                      width: indicatorWidth,
                    ),
                  ),
                ),
              Row(
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
            ],
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
    final Color contentColor = item.isShowcase
        ? AppColors.primary
        : isSelected
            ? AppColors.primary
            : AppColors.textSecondary(context);

    return Semantics(
      selected: isSelected,
      button: true,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: SizedBox.expand(
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: item.isShowcase ? 0 : 12,
                vertical: item.isShowcase ? 0 : 7,
              ),
              decoration: item.isShowcase
                  ? null
                  : BoxDecoration(
                      color: isSelected
                          ? AppColors.softPrimary(context)
                              .withValues(alpha: 0.82)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 8),
                  AnimatedScale(
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeOutBack,
                    scale: isSelected && !item.isShowcase ? 1.08 : 1,
                    child: item.isShowcase
                        ? Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
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
                        : Icon(
                            item.icon,
                            color: contentColor,
                            size: isSelected ? 22 : 20,
                          ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: isSelected && !item.isShowcase ? 10 : 9,
                      fontWeight: item.isShowcase || isSelected
                          ? FontWeight.w900
                          : FontWeight.w700,
                      height: 1,
                      letterSpacing: 0,
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 5),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: !item.isShowcase && isSelected ? 1 : 0,
                    child: Container(
                      width: 18,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

class _BottomNavGlow extends StatelessWidget {
  const _BottomNavGlow({
    required this.width,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.primary.withValues(alpha: 0.08),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );
  }
}

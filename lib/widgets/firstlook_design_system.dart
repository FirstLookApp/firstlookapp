import 'dart:async';

import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/feedback/app_feedback_service.dart';
import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class FirstLookScreenHeader extends ConsumerWidget {
  const FirstLookScreenHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int unreadNotificationCount =
        ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return Row(
      children: <Widget>[
        SizedBox(
          width: 76,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FirstLookIconButton(
              icon: Icons.grid_view_rounded,
              onTap: () => showFirstLookSettings(context, ref),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: InkResponse(
              onTap: () => context.go(RouteNames.discoverPath),
              radius: 34,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: FirstLookLogo(size: 33),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 76,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox.square(
                dimension: 36,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    FirstLookIconButton(
                      icon: Icons.notifications_none_rounded,
                      size: 19,
                      onTap: () => context.push(
                        RouteNames.notificationsLocation(
                          currentPath: GoRouterState.of(context).uri.path,
                        ),
                      ),
                    ),
                    if (unreadNotificationCount > 0)
                      Positioned(
                        left: -2,
                        top: -2,
                        child: _UnreadNotificationBadge(
                          count: unreadNotificationCount,
                        ),
                      ),
                  ],
                ),
              ),
              FirstLookIconButton(
                icon: Icons.search_rounded,
                size: 22,
                onTap: () => showFirstLookSearch(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnreadNotificationBadge extends StatelessWidget {
  const _UnreadNotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final String label = count > 99 ? '99+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border.all(color: Colors.white, width: 1.5),
        borderRadius: BorderRadius.circular(99),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class FirstLookIconButton extends StatelessWidget {
  const FirstLookIconButton({
    required this.icon,
    required this.onTap,
    this.size = 20,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () {
        AppFeedbackService.selection();
        onTap();
      },
      radius: 24,
      child: SizedBox.square(
        dimension: 36,
        child: Icon(icon, color: AppColors.primary, size: size),
      ),
    );
  }
}

class FirstLookSegmentedControl<T> extends StatelessWidget {
  const FirstLookSegmentedControl({
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
    this.height = 38,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt(context),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        children: values.map((T value) {
          final bool isSelected = value == selected;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
                child: Text(
                  labelBuilder(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FirstLookPrimaryButton extends StatelessWidget {
  const FirstLookPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed == null
            ? null
            : () {
                AppFeedbackService.selection();
                onPressed!();
              },
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 17),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.24),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
        ),
      ),
    );
  }
}

class FirstLookSoftCard extends StatelessWidget {
  const FirstLookSoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline(context)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.adaptiveShadow(context),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

Future<void> showFirstLookSettings(
  BuildContext context,
  WidgetRef ref,
) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (_) => const _FirstLookSettingsSheet(),
  );
}

class _FirstLookSettingsSheet extends ConsumerStatefulWidget {
  const _FirstLookSettingsSheet();

  @override
  ConsumerState<_FirstLookSettingsSheet> createState() =>
      _FirstLookSettingsSheetState();
}

class _FirstLookSettingsSheetState
    extends ConsumerState<_FirstLookSettingsSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _rateApp() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Uri uri = defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.parse('https://apps.apple.com/search?term=Firstlook')
        : Uri.parse(
            'https://play.google.com/store/apps/details?id=com.example.firstlook',
          );
    final bool opened =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsRateError)),
      );
    }
  }

  Animation<double> _cardAnimation(int index) => CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.12 + (index * 0.08),
          0.56 + (index * 0.08),
          curve: Curves.easeOutCubic,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AppFeedbackSettings settings = ref.watch(appFeedbackSettingsProvider);
    final Locale locale = ref.watch(appLocaleProvider);
    final bool darkModeEnabled = ref.watch(themeModeProvider) == ThemeMode.dark;
    final double height = MediaQuery.sizeOf(context).height * 0.74;

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 36,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2E7),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    children: <Widget>[
                      const FirstLookLogo(size: 27),
                      const SizedBox(height: 10),
                      Text(
                        l10n.settingsTitle,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        l10n.settingsSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _AnimatedSettingsItem(
                        animation: _cardAnimation(0),
                        child: _SettingsCard(
                          icon: Icons.language_rounded,
                          title: l10n.settingsLanguage,
                          subtitle: l10n.settingsLanguageSubtitle,
                          onTap: () =>
                              ref.read(appLocaleProvider.notifier).setLocale(
                                    Locale(
                                      locale.languageCode == 'tr' ? 'en' : 'tr',
                                    ),
                                  ),
                          trailing: SizedBox(
                            width: 116,
                            child: FirstLookSegmentedControl<String>(
                              values: const <String>['TR', 'EN'],
                              selected:
                                  locale.languageCode == 'tr' ? 'TR' : 'EN',
                              labelBuilder: (String value) => value,
                              onChanged: (String value) => ref
                                  .read(appLocaleProvider.notifier)
                                  .setLocale(Locale(value.toLowerCase())),
                              height: 36,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _AnimatedSettingsItem(
                        animation: _cardAnimation(1),
                        child: _SettingsCard(
                          icon: Icons.volume_up_outlined,
                          title: l10n.settingsNotifications,
                          subtitle: l10n.settingsSoundSubtitle,
                          onTap: () => ref
                              .read(appFeedbackSettingsProvider.notifier)
                              .setSoundEnabled(!settings.soundEnabled),
                          trailing: CupertinoSwitch(
                            value: settings.soundEnabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: (bool value) => ref
                                .read(appFeedbackSettingsProvider.notifier)
                                .setSoundEnabled(value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _AnimatedSettingsItem(
                        animation: _cardAnimation(2),
                        child: _SettingsCard(
                          icon: Icons.vibration_rounded,
                          title: l10n.settingsVibration,
                          subtitle: l10n.settingsVibrationSubtitle,
                          onTap: () => ref
                              .read(appFeedbackSettingsProvider.notifier)
                              .setVibrationEnabled(!settings.vibrationEnabled),
                          trailing: CupertinoSwitch(
                            value: settings.vibrationEnabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: (bool value) => ref
                                .read(appFeedbackSettingsProvider.notifier)
                                .setVibrationEnabled(value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _AnimatedSettingsItem(
                        animation: _cardAnimation(3),
                        child: _SettingsCard(
                          icon: Icons.star_outline_rounded,
                          title: l10n.settingsRateApp,
                          subtitle: l10n.settingsRateAppSubtitle,
                          onTap: _rateApp,
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSoft,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _AnimatedSettingsItem(
                        animation: _cardAnimation(4),
                        child: _SettingsCard(
                          icon: Icons.dark_mode_outlined,
                          iconColor: AppColors.textMuted,
                          iconBackground: AppColors.surfaceAlt(context),
                          title: l10n.settingsDarkMode,
                          subtitle: l10n.settingsDarkModeSubtitle,
                          onTap: () => ref
                              .read(themeModeProvider.notifier)
                              .setDarkMode(!darkModeEnabled),
                          trailing: CupertinoSwitch(
                            value: darkModeEnabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: (bool value) => ref
                                .read(themeModeProvider.notifier)
                                .setDarkMode(value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsLogoutButton(
                        label: l10n.logoutButton.toUpperCase(),
                        onPressed: () async {
                          final GoRouter router = GoRouter.of(context);
                          Navigator.of(context).pop();
                          await ref
                              .read(authControllerProvider.notifier)
                              .logout();
                          router.go(RouteNames.loginPath);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSettingsItem extends StatelessWidget {
  const _AnimatedSettingsItem({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.primarySoft,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outline(context)),
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.adaptiveShadow(context),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 10,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsLogoutButton extends StatefulWidget {
  const _SettingsLogoutButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_SettingsLogoutButton> createState() => _SettingsLogoutButtonState();
}

class _SettingsLogoutButtonState extends State<_SettingsLogoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: widget.onPressed,
            icon: const Icon(Icons.logout_rounded, size: 19),
            label: Text(widget.label),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showFirstLookSearch(
  BuildContext context,
  WidgetRef ref,
) {
  String sourcePath = RouteNames.discoverPath;
  try {
    sourcePath = GoRouterState.of(context).uri.path;
  } catch (_) {
    sourcePath = RouteNames.discoverPath;
  }

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) => _SearchSheet(sourcePath: sourcePath),
    transitionBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _SearchSheet extends ConsumerStatefulWidget {
  const _SearchSheet({
    required this.sourcePath,
  });

  final String sourcePath;

  @override
  ConsumerState<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends ConsumerState<_SearchSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  AsyncValue<_SearchResults> _results =
      const AsyncData<_SearchResults>(_SearchResults.empty());

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.sizeOf(context);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 430,
                maxHeight: screenSize.height * 0.72,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.adaptiveShadow(context),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 6, 6),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              onChanged: _onChanged,
                              decoration: InputDecoration(
                                hintText: l10n.searchHint,
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_controller.text.isEmpty) {
                                Navigator.of(context).pop();
                                return;
                              }
                              _controller.clear();
                              _onChanged('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                        children: <Widget>[
                          if (_controller.text.trim().length < 3)
                            _SearchEmpty(message: l10n.searchMinCharacters)
                          else
                            _results.when(
                              data: (_SearchResults results) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _SearchSectionTitle(
                                    title: l10n.searchApplications,
                                  ),
                                  const SizedBox(height: 8),
                                  if (results.applications.isEmpty)
                                    _SearchEmpty(message: l10n.commonNoData)
                                  else
                                    ...results.applications.map(
                                      (ApplicationListItem item) =>
                                          _SearchResultRow(
                                        item: item,
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          context.push(
                                            RouteNames
                                                .applicationDetailLocation(
                                              id: item.id,
                                              platform: item.platform,
                                              currentPath: widget.sourcePath,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  _SearchSectionTitle(title: l10n.searchUsers),
                                  const SizedBox(height: 8),
                                  if (results.users.isEmpty)
                                    _SearchEmpty(message: l10n.commonNoData)
                                  else
                                    ...results.users.map(
                                      (UserSearchItem item) =>
                                          _UserSearchResultRow(
                                        item: item,
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          context.push(
                                            RouteNames.userProfileLocation(
                                              item.userId,
                                              currentPath: widget.sourcePath,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                              error: (Object error, StackTrace stackTrace) =>
                                  _SearchEmpty(message: error.toString()),
                              loading: () => const Padding(
                                padding: EdgeInsets.all(30),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();

    final String query = value.trim();
    if (query.length < 3) {
      setState(
        () =>
            _results = const AsyncData<_SearchResults>(_SearchResults.empty()),
      );
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 360), () async {
      setState(() => _results = const AsyncLoading<_SearchResults>());

      try {
        final repository = ref.read(firstLookRepositoryProvider);
        final List<PagedResult<ApplicationListItem>> pages = await Future.wait(
          <Future<PagedResult<ApplicationListItem>>>[
            repository.searchApplications(search: query),
          ],
        );

        final Map<String, ApplicationListItem> unique =
            <String, ApplicationListItem>{};
        for (final PagedResult<ApplicationListItem> page in pages) {
          for (final ApplicationListItem item in page.items) {
            unique[item.id] = item;
          }
        }

        final PagedResult<UserSearchItem> userPage =
            await repository.searchUsers(search: query).catchError(
                  (_) => const PagedResult<UserSearchItem>(
                    items: <UserSearchItem>[],
                    pageNumber: 1,
                    pageSize: 20,
                    totalCount: 0,
                  ),
                );

        if (mounted) {
          setState(
            () => _results = AsyncData<_SearchResults>(
              _SearchResults(
                applications: unique.values.toList(),
                users: userPage.items,
              ),
            ),
          );
        }
      } catch (error, stackTrace) {
        if (mounted) {
          setState(
            () => _results = AsyncError<_SearchResults>(error, stackTrace),
          );
        }
      }
    });
  }
}

class _SearchResults {
  const _SearchResults({
    required this.applications,
    required this.users,
  });

  const _SearchResults.empty()
      : applications = const <ApplicationListItem>[],
        users = const <UserSearchItem>[];

  final List<ApplicationListItem> applications;
  final List<UserSearchItem> users;
}

class _SearchSectionTitle extends StatelessWidget {
  const _SearchSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w900,
          ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({
    required this.item,
    required this.onTap,
  });

  final ApplicationListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: item.mainScreenshot.isEmpty
            ? const Icon(Icons.apps_rounded, color: AppColors.primary)
            : Image.network(
                UrlResolver.media(item.mainScreenshot),
                fit: BoxFit.cover,
              ),
      ),
      title: Text(
        item.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        item.shortDescription,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _UserSearchResultRow extends StatelessWidget {
  const _UserSearchResultRow({
    required this.item,
    required this.onTap,
  });

  final UserSearchItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String title =
        item.fullName.trim().isEmpty ? item.username : item.fullName.trim();
    final String fallback = title.isEmpty ? '?' : title.characters.first;
    final String? avatarUrl = item.avatarUrl;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primarySoft,
        backgroundImage: avatarUrl == null || avatarUrl.isEmpty
            ? null
            : NetworkImage(UrlResolver.media(avatarUrl)),
        child: avatarUrl == null || avatarUrl.isEmpty
            ? Text(
                fallback.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              )
            : null,
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        '@${item.username} - ${item.totalApplications} ${l10n.profileStatsApps}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

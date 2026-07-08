import 'dart:async';

import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FirstLookScreenHeader extends ConsumerWidget {
  const FirstLookScreenHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FirstLookIconButton(
          icon: Icons.grid_view_rounded,
          onTap: () => showFirstLookSettings(context, ref),
        ),
        const FirstLookLogo(size: 33),
        FirstLookIconButton(
          icon: Icons.search_rounded,
          size: 27,
          onTap: () => showFirstLookSearch(context, ref),
        ),
      ],
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
      onTap: onTap,
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
        color: AppColors.chipFill,
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
                    color: isSelected ? Colors.white : AppColors.secondary,
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
        onPressed: onPressed,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 10),
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
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 46),
        child: FirstLookSoftCard(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const FirstLookLogo(size: 36),
              const SizedBox(height: 12),
              _SettingsRow(
                label: l10n.settingsLanguage,
                left: 'TR',
                right: 'EN',
                selectedLeft: true,
              ),
              _SettingsRow(
                label: l10n.settingsNotifications,
                left: l10n.settingsOn,
                right: l10n.settingsOff,
                selectedLeft: true,
              ),
              _SettingsRow(
                label: l10n.settingsVibration,
                left: l10n.settingsOn,
                right: l10n.settingsOff,
                selectedLeft: true,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                width: 136,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    ref.read(authControllerProvider.notifier).logout();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  child: Text(l10n.logoutButton.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.left,
    required this.right,
    required this.selectedLeft,
  });

  final String label;
  final String left;
  final String right;
  final bool selectedLeft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            height: 28,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.chipFill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: <Widget>[
                _SettingsPill(label: left, selected: selectedLeft),
                _SettingsPill(label: right, selected: !selectedLeft),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPill extends StatelessWidget {
  const _SettingsPill({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.secondary,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

Future<void> showFirstLookSearch(
  BuildContext context,
  WidgetRef ref,
) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.white,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) => const _SearchSheet(),
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
  const _SearchSheet();

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
              children: <Widget>[
                const FirstLookScreenHeader(),
                const SizedBox(height: 22),
                FirstLookSoftCard(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
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
                      const Divider(height: 1),
                      if (_controller.text.trim().length < 3)
                        _SearchEmpty(message: l10n.searchMinCharacters)
                      else
                        _results.when(
                          data: (_SearchResults results) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 10),
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
                                        RouteNames.applicationDetailLocation(
                                          id: item.id,
                                          platform: item.platform,
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
                                  (UserSearchItem item) => _UserSearchResultRow(
                                    item: item,
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      context.push(
                                        RouteNames.userProfileLocation(
                                          item.userId,
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
                            child: Center(child: CircularProgressIndicator()),
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
            repository.listApplications(
              destination: SubmitDestination.drop,
              platform: PlatformType.ios,
              search: query,
            ),
            repository.listApplications(
              destination: SubmitDestination.test,
              platform: PlatformType.ios,
              search: query,
            ),
            repository.listApplications(
              destination: SubmitDestination.drop,
              platform: PlatformType.android,
              search: query,
            ),
            repository.listApplications(
              destination: SubmitDestination.test,
              platform: PlatformType.android,
              search: query,
            ),
            repository.myApplications(
              search: query,
            ),
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
            color: AppColors.secondary,
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
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

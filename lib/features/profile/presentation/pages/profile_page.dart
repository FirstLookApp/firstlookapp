import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:firstlook/widgets/firstlook_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _showApplications = true;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<UserProfile> profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: profile.when(
          data: (UserProfile user) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(profileProvider);
              ref.invalidate(myApplicationsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 92),
              children: <Widget>[
                const FirstLookAppHeader(),
                const SizedBox(height: 28),
                _ProfileIdentity(user: user),
                const SizedBox(height: 20),
                _StatsCard(user: user),
                const SizedBox(height: 20),
                AuthPrimaryButton(
                  label: l10n.profilePromoteApp,
                  onPressed: null,
                ),
                const SizedBox(height: 20),
                _ProfileTabs(
                  showApplications: _showApplications,
                  onChanged: (bool value) =>
                      setState(() => _showApplications = value),
                ),
                const SizedBox(height: 16),
                if (_showApplications)
                  const _MyApplicationsList()
                else
                  _CommentsPlaceholder(message: l10n.profileCommentsTodo),
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).logout();
                  },
                  child: Text(l10n.logoutButton),
                ),
              ],
            ),
          ),
          error: (Object error, StackTrace stackTrace) => AppErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(profileProvider),
          ),
          loading: () => const AppLoadingIndicator(),
        ),
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({
    required this.user,
  });

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final String displayName = '${user.firstName} ${user.lastName}'.trim();

    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 42,
          backgroundColor: AppColors.primarySoft,
          backgroundImage:
              user.avatarUrl == null ? null : NetworkImage(user.avatarUrl!),
          child: user.avatarUrl == null
              ? Text(
                  user.firstName.isEmpty
                      ? '?'
                      : user.firstName.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          displayName.isEmpty ? user.username : displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.biography.isEmpty ? '@${user.username}' : user.biography,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.user,
  });

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          _Stat(label: l10n.profileStatsLikes, value: user.totalReceivedLikes),
          _Stat(
              label: l10n.profileStatsComments,
              value: user.totalReceivedComments),
          _Stat(label: l10n.profileStatsApps, value: user.totalApplications),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            _compactCount(value),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({
    required this.showApplications,
    required this.onChanged,
  });

  final bool showApplications;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          _TabButton(
            label: l10n.profileMyApps,
            selected: showApplications,
            onTap: () => onChanged(true),
          ),
          _TabButton(
            label: l10n.profileMyComments,
            selected: !showApplications,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _MyApplicationsList extends ConsumerWidget {
  const _MyApplicationsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PagedResult<ApplicationListItem>> applications =
        ref.watch(myApplicationsProvider);

    return applications.when(
      data: (PagedResult<ApplicationListItem> result) {
        if (result.items.isEmpty) {
          return const _CommentsPlaceholder(message: '');
        }

        return Column(
          children: result.items
              .map<Widget>((ApplicationListItem item) =>
                  _ProfileApplicationCard(item: item))
              .toList(),
        );
      },
      error: (Object error, StackTrace stackTrace) => Text(error.toString()),
      loading: () => const AppLoadingIndicator(),
    );
  }
}

class _ProfileApplicationCard extends StatelessWidget {
  const _ProfileApplicationCard({
    required this.item,
  });

  final ApplicationListItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: item.mainScreenshot.isEmpty
                  ? const ColoredBox(
                      color: AppColors.primarySoft,
                      child: Icon(Icons.apps_rounded, color: AppColors.primary),
                    )
                  : Image.network(
                      UrlResolver.media(item.mainScreenshot),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.shortDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _CommentsPlaceholder extends StatelessWidget {
  const _CommentsPlaceholder({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Text(
        message.isEmpty ? l10n.commonNoData : message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}

String _compactCount(int value) {
  if (value >= 1000) {
    final double compact = value / 1000;
    return '${compact.toStringAsFixed(compact >= 10 ? 0 : 1)}B';
  }
  return value.toString();
}

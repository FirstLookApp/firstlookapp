import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<UserProfile> profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: profile.when(
          data: (UserProfile user) => ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primarySoft,
                    child: Text(
                      user.firstName.isEmpty ? '?' : user.firstName[0],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        Text(
                          '@${user.username}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  _Stat(
                      label: l10n.profileStatsApps,
                      value: user.totalApplications),
                  _Stat(
                      label: l10n.profileStatsLikes,
                      value: user.totalReceivedLikes),
                  _Stat(
                      label: l10n.profileStatsComments,
                      value: user.totalReceivedComments),
                ],
              ),
              const SizedBox(height: 22),
              Text(user.biography),
              const SizedBox(height: 22),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.apps),
                title: Text(l10n.profileMyApps),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.comment),
                title: Text(l10n.profileMyComments),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).logout();
                },
                child: Text(l10n.logoutButton),
              ),
            ],
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
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

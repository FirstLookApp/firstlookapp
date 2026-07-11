import 'package:firstlook/core/errors/app_exception.dart';
import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserProfilePreviewPage extends ConsumerWidget {
  const UserProfilePreviewPage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PublicUserProfile> profile =
        ref.watch(publicUserProfileProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: profile.when(
          data: (PublicUserProfile user) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(publicUserProfileProvider(userId));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                12,
                AppSpacing.screenHorizontal,
                30,
              ),
              children: <Widget>[
                const _PreviewHeader(),
                const SizedBox(height: 28),
                _PublicProfileIdentity(user: user),
                const SizedBox(height: 20),
                _PublicStatsCard(user: user),
                const SizedBox(height: 24),
                _SectionTitle(
                  title: AppLocalizations.of(context)!.userProfilePublishedApps,
                ),
                const SizedBox(height: 12),
                if (user.applications.isEmpty)
                  _EmptyPublishedApps(
                    message: AppLocalizations.of(context)!.userProfileNoApps,
                  )
                else
                  ...user.applications.map(
                    (ApplicationListItem item) => _PublicApplicationCard(
                      item: item,
                      onTap: () => context.push(
                        RouteNames.applicationDetailLocation(
                          id: item.id,
                          platform: item.platform,
                          currentPath: GoRouterState.of(context).uri.path,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          error: (Object error, StackTrace stackTrace) => AppErrorState(
            message: error is AppException
                ? error.message
                : AppLocalizations.of(context)!.commonUnexpectedError,
            onRetry: () => ref.invalidate(publicUserProfileProvider(userId)),
          ),
          loading: () => const AppLoadingIndicator(),
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primary,
          ),
        ),
        const FirstLookLogo(size: 33),
        const SizedBox.square(dimension: 48),
      ],
    );
  }
}

class _PublicProfileIdentity extends StatelessWidget {
  const _PublicProfileIdentity({required this.user});

  final PublicUserProfile user;

  @override
  Widget build(BuildContext context) {
    final String displayName =
        user.fullName.trim().isEmpty ? user.username : user.fullName.trim();
    final String? avatarUrl = user.avatarUrl;
    final String fallback =
        displayName.isEmpty ? '?' : displayName.characters.first;

    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.primarySoft,
          backgroundImage: avatarUrl == null || avatarUrl.isEmpty
              ? null
              : NetworkImage(UrlResolver.media(avatarUrl)),
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Text(
                  fallback.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '@${user.username}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (user.biography.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            user.biography.trim(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _PublicStatsCard extends StatelessWidget {
  const _PublicStatsCard({required this.user});

  final PublicUserProfile user;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border.all(color: AppColors.outline(context)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.adaptiveShadow(context),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          _PublicStat(
            label: l10n.profileStatsLikes,
            value: user.totalReceivedLikes,
          ),
          _PublicStat(
            label: l10n.profileStatsComments,
            value: user.totalReceivedComments,
          ),
          _PublicStat(
            label: l10n.profileStatsApps,
            value: user.totalApplications,
          ),
        ],
      ),
    );
  }
}

class _PublicStat extends StatelessWidget {
  const _PublicStat({
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
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _PublicApplicationCard extends StatelessWidget {
  const _PublicApplicationCard({
    required this.item,
    required this.onTap,
  });

  final ApplicationListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          border: Border.all(color: AppColors.outline(context)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.adaptiveShadow(context),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
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
                        child:
                            Icon(Icons.apps_rounded, color: AppColors.primary),
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
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.shortDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPublishedApps extends StatelessWidget {
  const _EmptyPublishedApps({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary(context),
          fontSize: 13,
          fontWeight: FontWeight.w700,
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

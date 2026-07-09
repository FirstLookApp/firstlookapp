import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:firstlook/widgets/firstlook_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<ActiveDropBatch?> activeDrop =
        ref.watch(activeDropProvider);
    final String bannerTitle = activeDrop.maybeWhen(
      data: (ActiveDropBatch? drop) =>
          drop != null && drop.name.isNotEmpty ? drop.name : l10n.discoverTitle,
      orElse: () => l10n.discoverTitle,
    );
    final DateTime? bannerEndsAt = activeDrop.maybeWhen(
      data: (ActiveDropBatch? drop) => drop?.endsAt,
      orElse: () => null,
    );
    final String bannerDescription = activeDrop.maybeWhen(
      data: (ActiveDropBatch? drop) =>
          drop?.description.trim().isNotEmpty == true
              ? drop!.description.trim()
              : l10n.discoverSubtitle,
      orElse: () => l10n.discoverWeekBadge,
    );
    final String bannerBackgroundImagePath = activeDrop.maybeWhen(
      data: (ActiveDropBatch? drop) => drop?.backgroundImagePath ?? '',
      orElse: () => '',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(activeDropProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              12,
              AppSpacing.screenHorizontal,
              24,
            ),
            children: <Widget>[
              const FirstLookAppHeader(),
              const SizedBox(height: 24),
              _WeeklyBanner(
                title: bannerTitle,
                endsAt: bannerEndsAt,
                badge: bannerDescription,
                backgroundImagePath: bannerBackgroundImagePath,
              ),
              const SizedBox(height: 22),
              _SectionTitle(
                title: l10n.discoverSubtitle,
              ),
              const SizedBox(height: 12),
              activeDrop.when(
                data: (ActiveDropBatch? drop) {
                  final List<ApplicationListItem> items =
                      drop?.items ?? <ApplicationListItem>[];

                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          l10n.commonNoData,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: items.asMap().entries.map<Widget>(
                      (MapEntry<int, ApplicationListItem> entry) {
                        final ApplicationListItem item = entry.value;

                        return _DropAppCard(
                          item: item,
                          buttonLabel: l10n.discoverReviewButton,
                          onTap: () => context.push(
                            RouteNames.applicationDetailLocation(
                              id: item.id,
                              platform: item.platform,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  );
                },
                error: (Object error, StackTrace stackTrace) => AppErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(activeDropProvider),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: AppLoadingIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDropCountdown(
  BuildContext context,
  DateTime? endsAt,
  AppLocalizations l10n,
) {
  if (endsAt == null) {
    return l10n.discoverBannerTimer;
  }

  final Duration remaining = endsAt.toLocal().difference(DateTime.now());
  final bool isTurkish = Localizations.localeOf(context).languageCode == 'tr';
  if (remaining <= Duration.zero) {
    return isTurkish ? 'Drop sona erdi' : 'Drop ended';
  }

  final String duration = isTurkish
      ? '${remaining.inDays} gün ${remaining.inHours.remainder(24)} saat ${remaining.inMinutes.remainder(60)} dakika'
      : '${remaining.inDays}d ${remaining.inHours.remainder(24)}h ${remaining.inMinutes.remainder(60)}m';
  return isTurkish ? 'Bitişe $duration' : 'Ends in $duration';
}

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<PagedResult<ApplicationListItem>> leaderboard =
        ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(leaderboardProvider),
          child: leaderboard.when(
            data: (PagedResult<ApplicationListItem> result) {
              final List<ApplicationListItem> items = result.items;

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  12,
                  AppSpacing.screenHorizontal,
                  24,
                ),
                children: <Widget>[
                  const FirstLookAppHeader(),
                  const SizedBox(height: 28),
                  _SectionTitle(title: l10n.leaderboardTitle),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          l10n.commonNoData,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  else
                    _DropLeaderboard(
                      items: items,
                      buttonLabel: l10n.discoverReviewButton,
                      onTap: (ApplicationListItem item) => context.push(
                        RouteNames.applicationDetailLocation(
                          id: item.id,
                          platform: item.platform,
                          currentPath: RouteNames.leaderboardPath,
                        ),
                      ),
                    ),
                ],
              );
            },
            error: (Object error, StackTrace stackTrace) => AppErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(leaderboardProvider),
            ),
            loading: () => const AppLoadingIndicator(),
          ),
        ),
      ),
    );
  }
}

class _WeeklyBanner extends StatelessWidget {
  const _WeeklyBanner({
    required this.title,
    required this.endsAt,
    required this.badge,
    required this.backgroundImagePath,
  });

  final String title;
  final DateTime? endsAt;
  final String badge;
  final String backgroundImagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 176,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFFFF1F2), Color(0xFFFFD9DD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: <Widget>[
            if (backgroundImagePath.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  UrlResolver.media(backgroundImagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0xBF09121E),
                      Color(0x3309121E),
                      Color(0xE60B1018),
                    ],
                    stops: <double>[0, 0.42, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'DROP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        shadows: <Shadow>[
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<int>(
                      stream: Stream<int>.periodic(
                        const Duration(minutes: 1),
                        (int tick) => tick,
                      ),
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) {
                        final AppLocalizations l10n =
                            AppLocalizations.of(context)!;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.38),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.schedule_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDropCountdown(context, endsAt, l10n),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      badge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _DropLeaderboard extends StatelessWidget {
  const _DropLeaderboard({
    required this.items,
    required this.buttonLabel,
    required this.onTap,
  });

  final List<ApplicationListItem> items;
  final String buttonLabel;
  final ValueChanged<ApplicationListItem> onTap;

  @override
  Widget build(BuildContext context) {
    final List<ApplicationListItem> podiumItems = items.take(3).toList();
    final List<ApplicationListItem> rankedItems = items.skip(3).toList();

    return Column(
      children: <Widget>[
        if (podiumItems.isNotEmpty) ...<Widget>[
          _LeaderboardPodium(
            items: podiumItems,
            onTap: onTap,
          ),
          const SizedBox(height: 18),
        ],
        ...rankedItems.asMap().entries.map(
          (MapEntry<int, ApplicationListItem> entry) {
            return _RankedDropRow(
              rank: entry.key + 4,
              item: entry.value,
              buttonLabel: buttonLabel,
              onTap: () => onTap(entry.value),
            );
          },
        ),
      ],
    );
  }
}

class _LeaderboardPodium extends StatelessWidget {
  const _LeaderboardPodium({
    required this.items,
    required this.onTap,
  });

  final List<ApplicationListItem> items;
  final ValueChanged<ApplicationListItem> onTap;

  @override
  Widget build(BuildContext context) {
    final ApplicationListItem? first = _itemForRank(1);
    final ApplicationListItem? second = _itemForRank(2);
    final ApplicationListItem? third = _itemForRank(3);

    return SizedBox(
      height: 126,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: second == null
                ? const SizedBox.shrink()
                : _PodiumEntry(
                    rank: 2,
                    item: second,
                    badgeColor: const Color(0xFFD7DCE4),
                    badgeTextColor: AppColors.secondary,
                    imageSize: 58,
                    onTap: () => onTap(second),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: first == null
                ? const SizedBox.shrink()
                : _PodiumEntry(
                    rank: 1,
                    item: first,
                    badgeColor: const Color(0xFFFFD65A),
                    badgeTextColor: AppColors.secondary,
                    imageSize: 72,
                    isWinner: true,
                    onTap: () => onTap(first),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: third == null
                ? const SizedBox.shrink()
                : _PodiumEntry(
                    rank: 3,
                    item: third,
                    badgeColor: const Color(0xFFC8844E),
                    badgeTextColor: Colors.white,
                    imageSize: 58,
                    onTap: () => onTap(third),
                  ),
          ),
        ],
      ),
    );
  }

  ApplicationListItem? _itemForRank(int rank) {
    final int index = rank - 1;
    return index < items.length ? items[index] : null;
  }
}

class _PodiumEntry extends StatelessWidget {
  const _PodiumEntry({
    required this.rank,
    required this.item,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.imageSize,
    required this.onTap,
    this.isWinner = false,
  });

  final int rank;
  final ApplicationListItem item;
  final Color badgeColor;
  final Color badgeTextColor;
  final double imageSize;
  final VoidCallback onTap;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            width: imageSize + 18,
            height: imageSize + 18,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                _LeaderboardImage(
                  imagePath: item.mainScreenshot,
                  size: imageSize,
                  radius: imageSize * 0.28,
                ),
                Positioned(
                  top: -2,
                  child: _RankBadge(
                    rank: rank,
                    backgroundColor: badgeColor,
                    textColor: badgeTextColor,
                    size: isWinner ? 30 : 26,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: isWinner ? 13 : 12,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropAppCard extends StatelessWidget {
  const _DropAppCard({
    required this.item,
    required this.buttonLabel,
    required this.onTap,
  });

  final ApplicationListItem item;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            _LeaderboardImage(
              imagePath: item.mainScreenshot,
              size: 64,
              radius: 14,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                minimumSize: const Size(74, 36),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankedDropRow extends StatelessWidget {
  const _RankedDropRow({
    required this.rank,
    required this.item,
    required this.buttonLabel,
    required this.onTap,
  });

  final int rank;
  final ApplicationListItem item;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 24,
              child: Text(
                rank.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _LeaderboardImage(
              imagePath: item.mainScreenshot,
              size: 46,
              radius: 12,
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
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.shortDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                minimumSize: const Size(66, 34),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    required this.backgroundColor,
    required this.textColor,
    required this.size,
  });

  final int rank;
  final Color backgroundColor;
  final Color textColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        rank.toString(),
        style: TextStyle(
          color: textColor,
          fontSize: size * 0.48,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LeaderboardImage extends StatelessWidget {
  const _LeaderboardImage({
    required this.imagePath,
    required this.size,
    required this.radius,
  });

  final String imagePath;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: imagePath.isEmpty
            ? const ColoredBox(
                color: AppColors.primarySoft,
                child: Icon(
                  Icons.apps_rounded,
                  color: AppColors.primary,
                ),
              )
            : Image.network(
                UrlResolver.media(imagePath),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:firstlook/widgets/firstlook_app_header.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDeveloperPromptIfNeeded();
    });
  }

  Future<void> _showDeveloperPromptIfNeeded() async {
    if (!mounted || !ref.read(developerOnboardingPromptProvider)) {
      return;
    }

    ref.read(developerOnboardingPromptProvider.notifier).state = false;
    final bool isAuthenticated =
        ref.read(authControllerProvider).valueOrNull?.status ==
            AuthStatus.authenticated;
    if (isAuthenticated) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: AppColors.surface(dialogContext),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.outline(dialogContext)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const FirstLookLogo(size: 30),
              const SizedBox(height: 22),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.softPrimary(dialogContext),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.developerPromptTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary(dialogContext),
                  fontSize: 18,
                  height: 1.35,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.go(RouteNames.registerPath);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: Text(l10n.developerPromptRegister),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary(dialogContext),
                  minimumSize: const Size(double.infinity, 44),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text(l10n.developerPromptContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              : l10n.dropFallbackDescription,
      orElse: () => l10n.dropFallbackDescription,
    );
    final String bannerBackgroundImagePath = activeDrop.maybeWhen(
      data: (ActiveDropBatch? drop) => drop?.backgroundImagePath ?? '',
      orElse: () => '',
    );

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: ColoredBox(
        color: AppColors.background(context),
        child: SafeArea(
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
                const SizedBox(height: 26),
                activeDrop.when(
                  data: (ActiveDropBatch? drop) {
                    final List<ApplicationListItem> items =
                        drop?.items ?? <ApplicationListItem>[];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _DiscoverEntrance(
                          animation: _entranceController,
                          child: _WelcomeSection(dropCount: items.length),
                        ),
                        const SizedBox(height: 24),
                        _DiscoverEntrance(
                          animation: _entranceController,
                          scaleFrom: 0.985,
                          child: _WeeklyBanner(
                            title: bannerTitle,
                            endsAt: bannerEndsAt,
                            badge: bannerDescription,
                            backgroundImagePath: bannerBackgroundImagePath,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const _DiscoverSectionHeader(),
                        const SizedBox(height: 14),
                        if (items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                l10n.commonNoData,
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              border: Border.all(
                                color: AppColors.outline(context),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: items.asMap().entries.map<Widget>(
                                (MapEntry<int, ApplicationListItem> entry) {
                                  final ApplicationListItem item = entry.value;
                                  return _AnimatedRankedDropCard(
                                    key: ValueKey<String>(item.id),
                                    index: entry.key,
                                    isLast: entry.key == items.length - 1,
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
                            ),
                          ),
                        const SizedBox(height: 28),
                        const _CommunityRecommendations(),
                      ],
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
      ),
    );
  }
}

class _DiscoverEntrance extends StatelessWidget {
  const _DiscoverEntrance({
    required this.animation,
    required this.child,
    this.scaleFrom = 1,
  });

  final Animation<double> animation;
  final Widget child;
  final double scaleFrom;

  @override
  Widget build(BuildContext context) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: scaleFrom, end: 1).animate(curved),
        child: child,
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({required this.dropCount});

  final int dropCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.discoverWelcomeTitle,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 21,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                l10n.discoverWelcomeSubtitle,
                maxLines: 2,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 116,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.outline(context)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.adaptiveShadow(context),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.primary,
                size: 19,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.discoverDailyDiscovery,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 8.5,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Text(
                          '$dropCount',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.discoverNewLabel,
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiscoverSectionHeader extends StatelessWidget {
  const _DiscoverSectionHeader();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.discoverWeeklyDropsTitle,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.discoverWeeklyDropsSubtitle,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 11,
            height: 1.35,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _CommunityRecommendations extends StatelessWidget {
  const _CommunityRecommendations();

  static const List<(String, String, IconData, Color)> _items =
      <(String, String, IconData, Color)>[
    ('Zeynep K.', 'Focusly', Icons.bolt_rounded, Color(0xFF1AA66A)),
    ('Mert A.', 'Nomad', Icons.explore_rounded, Color(0xFF2774D8)),
    ('Elif D.', 'Frame', Icons.layers_rounded, Color(0xFFB67A08)),
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.discoverCommunityTitle,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 158,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (BuildContext context, int index) {
              final item = _items[index];
              return _CommunityPlaceholderCard(
                username: item.$1,
                applicationName: item.$2,
                applicationIcon: item.$3,
                applicationColor: item.$4,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CommunityPlaceholderCard extends StatelessWidget {
  const _CommunityPlaceholderCard({
    required this.username,
    required this.applicationName,
    required this.applicationIcon,
    required this.applicationColor,
  });

  final String username;
  final String applicationName;
  final IconData applicationIcon;
  final Color applicationColor;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Container(
      width: 286,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border.all(color: AppColors.outline(context)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  username.characters.first,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        l10n.discoverReviewerBadge,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(
                  5,
                  (_) => const Icon(
                    Icons.star_rounded,
                    color: AppColors.primary,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.discoverPlaceholderReview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 10,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt(context),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: applicationColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    applicationIcon,
                    color: applicationColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    applicationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.discoverReviewButton,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return l10n.dropEnded;
  }

  final String duration = isTurkish
      ? '${remaining.inDays} gün ${remaining.inHours.remainder(24)} saat ${remaining.inMinutes.remainder(60)} dakika'
      : '${remaining.inDays}d ${remaining.inHours.remainder(24)}h ${remaining.inMinutes.remainder(60)}m';
  return l10n.dropCountdown(duration);
}

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<PagedResult<ApplicationListItem>> leaderboard =
        ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: ColoredBox(
        color: AppColors.background(context),
        child: SafeArea(
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
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
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
        height: 158,
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
                child: Transform.scale(
                  scale: 1.035,
                  child: Image.network(
                    UrlResolver.media(backgroundImagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) =>
                        const SizedBox.shrink(),
                  ),
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
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
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
                        fontSize: 21,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        shadows: <Shadow>[
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
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
                    const SizedBox(height: 6),
                    Text(
                      badge,
                      maxLines: 1,
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
      style: TextStyle(
        color: AppColors.textPrimary(context),
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
                    badgeTextColor: AppColors.textPrimary(context),
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
                    badgeTextColor: AppColors.textPrimary(context),
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
              color: AppColors.textPrimary(context),
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

class _AnimatedRankedDropCard extends StatelessWidget {
  const _AnimatedRankedDropCard({
    required this.index,
    required this.isLast,
    required this.item,
    required this.buttonLabel,
    required this.onTap,
    super.key,
  });

  final int index;
  final bool isLast;
  final ApplicationListItem item;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 260 + (index.clamp(0, 6) * 15)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _RankedDiscoverCard(
        rank: index + 1,
        isLast: isLast,
        item: item,
        buttonLabel: buttonLabel,
        onTap: onTap,
      ),
    );
  }
}

class _RankedDiscoverCard extends StatelessWidget {
  const _RankedDiscoverCard({
    required this.rank,
    required this.isLast,
    required this.item,
    required this.buttonLabel,
    required this.onTap,
  });

  final int rank;
  final bool isLast;
  final ApplicationListItem item;
  final String buttonLabel;
  final VoidCallback onTap;

  Color get _badgeFill => switch (rank) {
        1 => const Color(0xFFFFB20F),
        2 => const Color(0xFFA9ADB5),
        3 => const Color(0xFFD96A19),
        _ => Colors.white,
      };

  Color get _badgeShadowColor => switch (rank) {
        1 => const Color(0xFFFFB20F),
        2 => const Color(0xFFA9ADB5),
        3 => const Color(0xFFA9ADB5),
        _ => Colors.transparent,
      };

  @override
  Widget build(BuildContext context) {
    final bool topThree = rank <= 3;
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.fromLTRB(38, 10, 10, 10),
          decoration: BoxDecoration(
            color: rank.isEven
                ? AppColors.surfaceAlt(context)
                : AppColors.surface(context),
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(color: AppColors.outline(context)),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _LeaderboardImage(
                  imagePath: item.mainScreenshot,
                  size: 40,
                  radius: 8,
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
                        fontSize: 13,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    if (item.category.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      item.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 10,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              SizedBox(
                width: 68,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _PressScaleButton(label: buttonLabel, onPressed: onTap),
                    if (item.score > 0) ...<Widget>[
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.favorite_rounded,
                            color: AppColors.textSecondary(context),
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.score.toStringAsFixed(1),
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 9,
          top: 0,
          bottom: 12,
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _badgeFill,
                shape: BoxShape.circle,
                border: Border.all(
                  color: topThree ? Colors.white : AppColors.outline(context),
                  width: topThree ? 1.3 : 1,
                ),
                boxShadow: topThree
                    ? <BoxShadow>[
                        BoxShadow(
                          color: _badgeShadowColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color:
                      topThree ? Colors.white : AppColors.textPrimary(context),
                  fontSize: 9,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PressScaleButton extends StatefulWidget {
  const _PressScaleButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_PressScaleButton> createState() => _PressScaleButtonState();
}

class _PressScaleButtonState extends State<_PressScaleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: FilledButton(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size(62, 34),
            padding: const EdgeInsets.symmetric(horizontal: 11),
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          child: Text(widget.label),
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
          color: AppColors.surface(context),
          border: Border.all(color: AppColors.outline(context)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.adaptiveShadow(context),
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
                style: TextStyle(
                  color: AppColors.textSecondary(context),
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
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
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
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
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

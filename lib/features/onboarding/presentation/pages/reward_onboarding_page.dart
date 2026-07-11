import 'dart:math' as math;

import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:firstlook/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const Color _gold = Color(0xFFF5B301);
const Color _background = Color(0xFFFAFAFA);

class RewardOnboardingPage extends ConsumerStatefulWidget {
  const RewardOnboardingPage({super.key});

  @override
  ConsumerState<RewardOnboardingPage> createState() =>
      _RewardOnboardingPageState();
}

class _RewardOnboardingPageState extends ConsumerState<RewardOnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _title;
  late final Animation<double> _subtitle;
  late final Animation<double> _phone;
  late final Animation<double> _topThree;
  late final Animation<double> _rewards;
  late final Animation<double> _features;
  late final Animation<double> _cta;
  late final List<Animation<double>> _cards;
  bool _started = false;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
    _title = _interval(0, 0.24);
    _subtitle = _interval(0.1, 0.38);
    _phone = _interval(0.18, 0.62);
    _topThree = _interval(0.32, 0.72);
    _rewards = _interval(0.26, 0.66);
    _features = _interval(0.6, 0.88);
    _cta = _interval(0.74, 1);
    _cards = <Animation<double>>[
      _interval(0.38, 0.64),
      _interval(0.48, 0.74),
      _interval(0.56, 0.82),
    ];
  }

  Animation<double> _interval(double begin, double end) => CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: Curves.easeInOutCubic),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete({bool showDeveloperPrompt = false}) async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    try {
      if (showDeveloperPrompt) {
        ref.read(developerOnboardingPromptProvider.notifier).state = true;
      }
      await ref.read(onboardingControllerProvider.notifier).complete();
      if (mounted) {
        context.go(RouteNames.discoverPath);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.commonUnexpectedError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxHeight < 790;
            final double heroHeight = compact ? 270 : 350;
            final double padding = compact ? 12 : 18;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                padding,
                AppSpacing.screenHorizontal,
                18,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - padding - 18,
                ),
                child: Column(
                  children: <Widget>[
                    _Header(
                      compact: compact,
                      titleAnimation: _title,
                      subtitleAnimation: _subtitle,
                      l10n: l10n,
                    ),
                    SizedBox(height: compact ? 12 : 18),
                    _RewardHero(
                      height: heroHeight,
                      phoneAnimation: _phone,
                      topThreeAnimation: _topThree,
                      rewardAnimation: _rewards,
                      cardAnimations: _cards,
                      l10n: l10n,
                    ),
                    SizedBox(height: compact ? 12 : 18),
                    OnboardingFadeSlide(
                      animation: _features,
                      offset: 0.045,
                      child: OnboardingFeaturePanel(
                        labels: <String>[
                          l10n.onboardingFeatureLeaderboard,
                          l10n.onboardingFeatureBadges,
                          l10n.onboardingFeatureDailyTasks,
                        ],
                        icons: const <IconData>[
                          Icons.upload_rounded,
                          Icons.favorite_rounded,
                          Icons.trending_up_rounded,
                        ],
                        iconColors: const <Color>[
                          AppColors.primary,
                          AppColors.primary,
                          _gold,
                        ],
                        showChevrons: true,
                      ),
                    ),
                    SizedBox(height: compact ? 16 : 22),
                    OnboardingFadeSlide(
                      animation: _cta,
                      offset: 0.12,
                      child: Column(
                        children: <Widget>[
                          AuthPrimaryButton(
                            label: l10n.onboardingStartDiscovering,
                            isLoading: _isCompleting,
                            onPressed: () =>
                                _complete(showDeveloperPrompt: true),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: _isCompleting ? null : () => _complete(),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textMuted,
                              minimumSize: const Size(88, 42),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                            child: Text(l10n.onboardingSkip),
                          ),
                          const SizedBox(height: 8),
                          const OnboardingPageIndicator(activeIndex: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.compact,
    required this.titleAnimation,
    required this.subtitleAnimation,
    required this.l10n,
  });

  final bool compact;
  final Animation<double> titleAnimation;
  final Animation<double> subtitleAnimation;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          FadeTransition(
            opacity: titleAnimation,
            child: FirstLookLogo(size: compact ? 25 : 28),
          ),
          SizedBox(height: compact ? 12 : 16),
          OnboardingFadeSlide(
            animation: titleAnimation,
            offset: 0.05,
            child: Text(
              l10n.onboardingRewardsTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: compact ? 28 : 32,
                fontWeight: FontWeight.w900,
                height: 1.05,
                letterSpacing: 0,
              ),
            ),
          ),
          SizedBox(height: compact ? 7 : 9),
          OnboardingFadeSlide(
            animation: subtitleAnimation,
            offset: 0.045,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 345),
              child: Text(
                l10n.onboardingRewardsSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: compact ? 12.5 : 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      );
}

class _RewardHero extends StatelessWidget {
  const _RewardHero({
    required this.height,
    required this.phoneAnimation,
    required this.topThreeAnimation,
    required this.rewardAnimation,
    required this.cardAnimations,
    required this.l10n,
  });

  final double height;
  final Animation<double> phoneAnimation;
  final Animation<double> topThreeAnimation;
  final Animation<double> rewardAnimation;
  final List<Animation<double>> cardAnimations;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: height,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final double phoneHeight = height - 4;
            final double phoneWidth =
                math.min(width * 0.48, phoneHeight * 0.52);
            final double cardWidth = math.min(112, width * 0.29);
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  left: width * 0.04,
                  top: height * 0.02,
                  child: _RewardSignal(
                    animation: rewardAnimation,
                    icon: Icons.emoji_events_rounded,
                    size: 40,
                  ),
                ),
                Positioned(
                  right: width * 0.06,
                  top: height * 0.04,
                  child: _RewardSignal(
                    animation: rewardAnimation,
                    icon: Icons.workspace_premium_rounded,
                    size: 36,
                  ),
                ),
                Positioned(
                  right: width * 0.13,
                  bottom: height * 0.04,
                  child: FadeTransition(
                    opacity: rewardAnimation,
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: _gold, size: 22),
                  ),
                ),
                OnboardingFadeSlide(
                  animation: phoneAnimation,
                  offset: 0.1,
                  child: _LeaderboardPhone(
                    width: phoneWidth,
                    height: phoneHeight,
                    topThreeAnimation: topThreeAnimation,
                    l10n: l10n,
                  ),
                ),
                Positioned(
                  left: 0,
                  top: height * 0.25,
                  child: _AchievementCard(
                    animation: cardAnimations[0],
                    width: cardWidth,
                    icon: Icons.emoji_events_rounded,
                    title: l10n.onboardingAchievementLeader,
                    value: '2.4K beğeni',
                  ),
                ),
                Positioned(
                  right: 0,
                  top: height * 0.43,
                  child: _AchievementCard(
                    animation: cardAnimations[1],
                    width: cardWidth,
                    icon: Icons.trending_up_rounded,
                    title: l10n.onboardingAchievementBadge,
                    value: '+320 beğeni',
                  ),
                ),
                Positioned(
                  left: 2,
                  bottom: height * 0.03,
                  child: _AchievementCard(
                    animation: cardAnimations[2],
                    width: cardWidth,
                    icon: Icons.rocket_launch_rounded,
                    iconColor: AppColors.primary,
                    title: l10n.onboardingAchievementActive,
                    value: 'İlk 100 beğeni',
                  ),
                ),
              ],
            );
          },
        ),
      );
}

class _LeaderboardPhone extends StatelessWidget {
  const _LeaderboardPhone({
    required this.width,
    required this.height,
    required this.topThreeAnimation,
    required this.l10n,
  });

  final double width;
  final double height;
  final Animation<double> topThreeAnimation;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final double s = width / 190;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(4 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF171719),
        borderRadius: BorderRadius.circular(31 * s),
        border: Border.all(color: const Color(0xFF4A4A4F)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: _gold.withValues(alpha: 0.08),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27 * s),
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(9 * s, 7 * s, 9 * s, 4 * s),
            child: Column(
              children: <Widget>[
                _StatusBar(scale: s),
                SizedBox(height: 5 * s),
                Row(
                  children: <Widget>[
                    Icon(Icons.grid_view_rounded,
                        color: AppColors.primary, size: 13 * s),
                    const Spacer(),
                    FirstLookLogo(size: 12.5 * s),
                    const Spacer(),
                    Icon(Icons.search_rounded,
                        color: AppColors.primary, size: 15 * s),
                  ],
                ),
                SizedBox(height: 7 * s),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.onboardingAppLeaderboard,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(height: 5 * s),
                _PeriodTabs(scale: s),
                SizedBox(height: 7 * s),
                FadeTransition(
                  opacity: topThreeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.14),
                      end: Offset.zero,
                    ).animate(topThreeAnimation),
                    child: _MiniPodium(scale: s),
                  ),
                ),
                SizedBox(height: 6 * s),
                Expanded(
                  child: _RankList(
                    scale: s,
                    likesLabel: l10n.onboardingLikesLabel,
                  ),
                ),
                SizedBox(height: 2 * s),
                _MiniBottomNav(scale: s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.scale});
  final double scale;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 12 * scale,
        child: Row(
          children: <Widget>[
            Text('9:41',
                style: TextStyle(
                    fontSize: 6.5 * scale,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0)),
            const Spacer(),
            Container(
                width: 37 * scale,
                height: 10 * scale,
                decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8 * scale))),
            const Spacer(),
            Icon(Icons.battery_full_rounded, size: 9 * scale),
          ],
        ),
      );
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.scale});
  final double scale;
  @override
  Widget build(BuildContext context) => Container(
        height: 20 * scale,
        decoration: BoxDecoration(
            color: const Color(0xFFF4F4F5),
            borderRadius: BorderRadius.circular(8 * scale)),
        child: Row(children: <Widget>[
          Expanded(
              child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8 * scale)),
                  child: Text('Bu Hafta',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 5.5 * scale,
                          fontWeight: FontWeight.w800)))),
          Expanded(
              child: Center(
                  child: Text('Bu Ay',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 5.5 * scale)))),
          Expanded(
              child: Center(
                  child: Text('Tümü',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 5.5 * scale)))),
        ]),
      );
}

class _MiniPodium extends StatelessWidget {
  const _MiniPodium({required this.scale});
  final double scale;
  @override
  Widget build(BuildContext context) {
    const data = <(int, String, String, Color, IconData)>[
      (2, 'Focusly', '1.280', Color(0xFFD7DCE4), Icons.bolt_rounded),
      (1, 'Nomad', '1.520', Color(0xFFFFD65A), Icons.explore_rounded),
      (3, 'Frame', '980', Color(0xFFC8844E), Icons.layers_rounded),
    ];
    return SizedBox(
      height: 76 * scale,
      child: Row(
          children: data.map((item) {
        final bool winner = item.$1 == 1;
        return Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
              Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                        width: (winner ? 40 : 34) * scale,
                        height: (winner ? 40 : 34) * scale,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(10 * scale)),
                        child: Icon(item.$5,
                            color: AppColors.primary,
                            size: (winner ? 20 : 17) * scale)),
                    Positioned(
                        top: -6 * scale,
                        child: Container(
                            width: 16 * scale,
                            height: 16 * scale,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: item.$4,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 1.2 * scale)),
                            child: Text('${item.$1}',
                                style: TextStyle(
                                    fontSize: 7 * scale,
                                    fontWeight: FontWeight.w900)))),
                  ]),
              SizedBox(height: 4 * scale),
              Text(item.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 6.5 * scale,
                      fontWeight: FontWeight.w900,
                      height: 1)),
              Text(item.$3,
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 6 * scale,
                      fontWeight: FontWeight.w900,
                      height: 1)),
            ]));
      }).toList()),
    );
  }
}

class _RankList extends StatelessWidget {
  const _RankList({required this.scale, required this.likesLabel});
  final double scale;
  final String likesLabel;
  @override
  Widget build(BuildContext context) {
    const names = <String>['Pulse', 'Taskio', 'Canvas', 'Moodly', 'Loop'];
    const icons = <IconData>[
      Icons.favorite_rounded,
      Icons.check_circle_rounded,
      Icons.palette_rounded,
      Icons.sentiment_satisfied_rounded,
      Icons.all_inclusive_rounded,
    ];
    const points = <String>['750', '620', '540', '390', '310'];
    return Column(
        children: List<Widget>.generate(names.length, (int index) {
      return Expanded(
          child: Container(
              margin: EdgeInsets.only(bottom: 3 * scale),
              padding: EdgeInsets.symmetric(horizontal: 5 * scale),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(7 * scale)),
              child: Row(children: <Widget>[
                SizedBox(
                    width: 12 * scale,
                    child: Text('${index + 4}',
                        style: TextStyle(
                            fontSize: 5.5 * scale,
                            fontWeight: FontWeight.w900))),
                Container(
                    width: 11 * scale,
                    height: 11 * scale,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(3 * scale)),
                    child: Icon(icons[index],
                        size: 6 * scale, color: AppColors.primary)),
                SizedBox(width: 4 * scale),
                Expanded(
                    child: Text(names[index],
                        style: TextStyle(
                            fontSize: 5.7 * scale,
                            fontWeight: FontWeight.w800))),
                Text(points[index],
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 5.5 * scale,
                        fontWeight: FontWeight.w900)),
                SizedBox(width: 2 * scale),
                Text(likesLabel,
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 4.5 * scale)),
              ])));
    }));
  }
}

class _MiniBottomNav extends StatelessWidget {
  const _MiniBottomNav({required this.scale});
  final double scale;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 18 * scale,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const <IconData>[
              Icons.explore_outlined,
              Icons.leaderboard_rounded,
              Icons.add_circle_outline_rounded,
              Icons.favorite_border_rounded,
              Icons.person_outline_rounded,
            ]
                .asMap()
                .entries
                .map((entry) => Icon(entry.value,
                    color:
                        entry.key == 1 ? AppColors.primary : AppColors.textSoft,
                    size: 10.5 * scale))
                .toList()),
      );
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard(
      {required this.animation,
      required this.width,
      required this.icon,
      required this.title,
      required this.value,
      this.iconColor = _gold});
  final Animation<double> animation;
  final double width;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    final double s = width / 112;
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
          scale: Tween<double>(begin: .95, end: 1).animate(animation),
          child: Container(
              width: width,
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14 * s),
                  border: Border.all(color: AppColors.border),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 16 * s,
                        offset: Offset(0, 8 * s))
                  ]),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Container(
                    width: 32 * s,
                    height: 32 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(11 * s)),
                    child: Icon(icon, color: iconColor, size: 19 * s)),
                SizedBox(height: 7 * s),
                Text(title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 8.5 * s,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: 0)),
                SizedBox(height: 4 * s),
                Text(value,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 8 * s,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0)),
              ]))),
    );
  }
}

class _RewardSignal extends StatelessWidget {
  const _RewardSignal(
      {required this.animation, required this.icon, required this.size});
  final Animation<double> animation;
  final IconData icon;
  final double size;
  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: animation,
      child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _gold.withValues(alpha: .18)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 14,
                    offset: Offset(0, 7))
              ]),
          child: Icon(icon, color: _gold, size: size * .5)));
}

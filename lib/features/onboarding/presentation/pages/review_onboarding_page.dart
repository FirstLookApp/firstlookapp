import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:firstlook/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const Color _reviewBackground = Color(0xFFFAFAFA);

class ReviewOnboardingPage extends ConsumerStatefulWidget {
  const ReviewOnboardingPage({super.key});

  @override
  ConsumerState<ReviewOnboardingPage> createState() =>
      _ReviewOnboardingPageState();
}

class _ReviewOnboardingPageState extends ConsumerState<ReviewOnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _titleAnimation;
  late final Animation<double> _subtitleAnimation;
  late final Animation<double> _phoneAnimation;
  late final Animation<double> _detailScrollAnimation;
  late final Animation<double> _iconsAnimation;
  late final Animation<double> _featuresAnimation;
  late final Animation<double> _ctaAnimation;
  late final List<Animation<double>> _reviewCardAnimations;
  bool _animationStarted = false;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titleAnimation = _interval(0, 0.25);
    _subtitleAnimation = _interval(0.1, 0.4);
    _phoneAnimation = _interval(0.18, 0.62);
    _detailScrollAnimation = _interval(0.32, 0.82);
    _iconsAnimation = _interval(0.28, 0.68);
    _featuresAnimation = _interval(0.58, 0.88);
    _ctaAnimation = _interval(0.72, 1);
    _reviewCardAnimations = <Animation<double>>[
      _interval(0.34, 0.62),
      _interval(0.44, 0.72),
      _interval(0.54, 0.82),
    ];
  }

  Animation<double> _interval(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationStarted) {
      return;
    }

    _animationStarted = true;
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
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

  Future<void> _completeOnboarding() async {
    if (_isCompleting) {
      return;
    }

    setState(() => _isCompleting = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).complete();
    } catch (_) {
      if (mounted) {
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonUnexpectedError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  void _showRewardsStep() {
    context.push(RouteNames.onboardingRewardsPath);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _reviewBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxHeight < 790;
            final double heroHeight = compact ? 260 : 350;
            final double verticalPadding = compact ? 12 : 18;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                verticalPadding,
                AppSpacing.screenHorizontal,
                18,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (verticalPadding + 18),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      _ReviewHeader(
                        compact: compact,
                        title: l10n.onboardingReviewTitle,
                        subtitle: l10n.onboardingReviewSubtitle,
                        titleAnimation: _titleAnimation,
                        subtitleAnimation: _subtitleAnimation,
                      ),
                      SizedBox(height: compact ? 12 : 18),
                      _ReviewHero(
                        height: heroHeight,
                        phoneAnimation: _phoneAnimation,
                        detailScrollAnimation: _detailScrollAnimation,
                        iconsAnimation: _iconsAnimation,
                        reviewCardAnimations: _reviewCardAnimations,
                        l10n: l10n,
                      ),
                      SizedBox(height: compact ? 12 : 18),
                      OnboardingFadeSlide(
                        animation: _featuresAnimation,
                        offset: 0.045,
                        child: OnboardingFeaturePanel(
                          labels: <String>[
                            l10n.onboardingFeatureRealReviews,
                            l10n.onboardingFeatureTrustedRatings,
                            l10n.onboardingFeatureCommunityExperience,
                          ],
                        ),
                      ),
                      SizedBox(height: compact ? 16 : 22),
                      const Spacer(),
                      OnboardingFadeSlide(
                        animation: _ctaAnimation,
                        offset: 0.12,
                        child: Column(
                          children: <Widget>[
                            AuthPrimaryButton(
                              label: l10n.onboardingShareExperience,
                              onPressed: _showRewardsStep,
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed:
                                  _isCompleting ? null : _completeOnboarding,
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
                            const OnboardingPageIndicator(activeIndex: 1),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({
    required this.compact,
    required this.title,
    required this.subtitle,
    required this.titleAnimation,
    required this.subtitleAnimation,
  });

  final bool compact;
  final String title;
  final String subtitle;
  final Animation<double> titleAnimation;
  final Animation<double> subtitleAnimation;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: compact ? 29 : 33,
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
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: compact ? 13 : 14,
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
}

class _ReviewHero extends StatelessWidget {
  const _ReviewHero({
    required this.height,
    required this.phoneAnimation,
    required this.detailScrollAnimation,
    required this.iconsAnimation,
    required this.reviewCardAnimations,
    required this.l10n,
  });

  final double height;
  final Animation<double> phoneAnimation;
  final Animation<double> detailScrollAnimation;
  final Animation<double> iconsAnimation;
  final List<Animation<double>> reviewCardAnimations;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double phoneHeight = height - 4;
          final double phoneWidth = math.min(width * 0.51, phoneHeight * 0.56);
          final double cardWidth = math.min(132, width * 0.35);
          final double cardHeight = cardWidth * 0.84;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                left: width * 0.08,
                top: 2,
                child: _FloatingSignal(
                  animation: iconsAnimation,
                  icon: Icons.favorite_rounded,
                  size: 38,
                  rise: 0.16,
                ),
              ),
              Positioned(
                right: width * 0.08,
                top: height * 0.04,
                child: _FloatingSignal(
                  animation: iconsAnimation,
                  icon: Icons.star_rounded,
                  size: 36,
                  rise: 0.08,
                ),
              ),
              Positioned(
                left: width * 0.1,
                bottom: height * 0.02,
                child: _FloatingSignal(
                  animation: iconsAnimation,
                  icon: Icons.chat_bubble_rounded,
                  size: 35,
                  rise: 0.1,
                ),
              ),
              Positioned(
                right: width * 0.09,
                bottom: height * 0.05,
                child: _FloatingSignal(
                  animation: iconsAnimation,
                  icon: Icons.thumb_up_rounded,
                  size: 37,
                  rise: 0.12,
                ),
              ),
              OnboardingFadeSlide(
                animation: phoneAnimation,
                offset: 0.09,
                child: _DetailPhoneMockup(
                  width: phoneWidth,
                  height: phoneHeight,
                  scrollAnimation: detailScrollAnimation,
                  l10n: l10n,
                ),
              ),
              Positioned(
                left: 0,
                top: height * 0.22,
                child: _AnimatedReviewCard(
                  animation: reviewCardAnimations[0],
                  child: _FloatingReviewCard(
                    width: cardWidth,
                    height: cardHeight,
                    rating: 5,
                    comment: l10n.onboardingReviewCommentOne,
                    helpful: l10n.onboardingHelpfulCount(124),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: height * 0.42,
                child: _AnimatedReviewCard(
                  animation: reviewCardAnimations[1],
                  child: _FloatingReviewCard(
                    width: cardWidth,
                    height: cardHeight,
                    rating: 4,
                    comment: l10n.onboardingReviewCommentTwo,
                    helpful: l10n.onboardingHelpfulCount(82),
                  ),
                ),
              ),
              Positioned(
                left: 4,
                bottom: height * 0.07,
                child: _AnimatedReviewCard(
                  animation: reviewCardAnimations[2],
                  child: _FloatingReviewCard(
                    width: cardWidth,
                    height: cardHeight,
                    rating: 5,
                    comment: l10n.onboardingReviewCommentThree,
                    helpful: l10n.onboardingHelpfulCount(57),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailPhoneMockup extends StatelessWidget {
  const _DetailPhoneMockup({
    required this.width,
    required this.height,
    required this.scrollAnimation,
    required this.l10n,
  });

  final double width;
  final double height;
  final Animation<double> scrollAnimation;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final double scale = width / 190;

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF171719),
        borderRadius: BorderRadius.circular(31 * scale),
        border: Border.all(color: const Color(0xFF4A4A4F), width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27 * scale),
        child: ColoredBox(
          color: Colors.white,
          child: AnimatedBuilder(
            animation: scrollAnimation,
            builder: (BuildContext context, Widget? child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  ui.lerpDouble(7 * scale, -5 * scale, scrollAnimation.value)!,
                ),
                child: child,
              );
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                9 * scale,
                7 * scale,
                9 * scale,
                2 * scale,
              ),
              child: Column(
                children: <Widget>[
                  _DetailPhoneStatusBar(scale: scale),
                  SizedBox(height: 5 * scale),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textMuted,
                        size: 10 * scale,
                      ),
                      const Spacer(),
                      FirstLookLogo(size: 12.5 * scale),
                      const Spacer(),
                      Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 15 * scale,
                      ),
                    ],
                  ),
                  SizedBox(height: 7 * scale),
                  _MiniAppBanner(scale: scale),
                  SizedBox(height: 7 * scale),
                  _MiniSectionTitle(label: l10n.detailAbout, scale: scale),
                  SizedBox(height: 3 * scale),
                  _DescriptionLines(scale: scale),
                  SizedBox(height: 6 * scale),
                  _MiniSectionTitle(label: l10n.detailComments, scale: scale),
                  SizedBox(height: 4 * scale),
                  _MiniRatingPanel(scale: scale),
                  SizedBox(height: 5 * scale),
                  _MiniCommentCard(
                    scale: scale,
                    username: 'Lina',
                    comment: l10n.onboardingReviewCommentOne,
                  ),
                  SizedBox(height: 5 * scale),
                  _MiniCommentCard(
                    scale: scale,
                    username: 'Mert',
                    comment: l10n.onboardingReviewCommentTwo,
                  ),
                  const Spacer(),
                  _DetailPhoneBottomNav(scale: scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailPhoneStatusBar extends StatelessWidget {
  const _DetailPhoneStatusBar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12 * scale,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '9:41',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 6.5 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          Container(
            width: 37 * scale,
            height: 10 * scale,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8 * scale),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.battery_full_rounded,
              color: AppColors.secondary,
              size: 9 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAppBanner extends StatelessWidget {
  const _MiniAppBanner({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54 * scale,
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38 * scale,
            height: 38 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10 * scale),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: AppColors.shadow, blurRadius: 8),
              ],
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: AppColors.primary,
              size: 23 * scale,
            ),
          ),
          SizedBox(width: 7 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Focusly',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 9 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.star_rounded,
                      color: AppColors.primary,
                      size: 9 * scale,
                    ),
                    Text(
                      '4.8',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 6 * scale,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6 * scale,
              vertical: 4 * scale,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(7 * scale),
            ),
            child: Text(
              '4.8',
              style: TextStyle(
                color: Colors.white,
                fontSize: 6 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSectionTitle extends StatelessWidget {
  const _MiniSectionTitle({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 7.2 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _DescriptionLines extends StatelessWidget {
  const _DescriptionLines({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final double widthFactor in <double>[1, 0.92, 0.72])
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              child: Container(
                height: 3.2 * scale,
                margin: EdgeInsets.only(bottom: 3 * scale),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MiniRatingPanel extends StatelessWidget {
  const _MiniRatingPanel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50 * scale,
      padding: EdgeInsets.all(6 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 38 * scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '4.8',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                _StarRow(rating: 5, size: 5.5 * scale),
              ],
            ),
          ),
          SizedBox(width: 5 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (final double factor in <double>[
                  0.92,
                  0.7,
                  0.45,
                  0.24,
                  0.1
                ])
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.1 * scale),
                    child: LinearProgressIndicator(
                      minHeight: 2.4 * scale,
                      value: factor,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(99),
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

class _MiniCommentCard extends StatelessWidget {
  const _MiniCommentCard({
    required this.scale,
    required this.username,
    required this.comment,
  });

  final double scale;
  final String username;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42 * scale,
      width: double.infinity,
      padding: EdgeInsets.all(6 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: AppColors.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 9 * scale,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              username.characters.first,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 6 * scale,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 5 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      username,
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 6 * scale,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(width: 4 * scale),
                    _StarRow(rating: 5, size: 4.5 * scale),
                  ],
                ),
                SizedBox(height: 2 * scale),
                Text(
                  comment,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF62626A),
                    fontSize: 5.5 * scale,
                    height: 1.2,
                    letterSpacing: 0,
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

class _DetailPhoneBottomNav extends StatelessWidget {
  const _DetailPhoneBottomNav({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    const List<IconData> icons = <IconData>[
      Icons.local_fire_department_outlined,
      Icons.leaderboard_outlined,
      Icons.article_rounded,
      Icons.add_circle_outline_rounded,
      Icons.person_outline_rounded,
    ];

    return SizedBox(
      height: 22 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: icons.asMap().entries.map((MapEntry<int, IconData> entry) {
          final bool showcase = entry.key == 2;
          return Container(
            width: 21 * scale,
            height: 21 * scale,
            alignment: Alignment.center,
            decoration: showcase
                ? BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6 * scale),
                  )
                : null,
            child: Icon(
              entry.value,
              color: showcase ? Colors.white : AppColors.textSoft,
              size: 10.5 * scale,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AnimatedReviewCard extends StatelessWidget {
  const _AnimatedReviewCard({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1).animate(animation),
        child: child,
      ),
    );
  }
}

class _FloatingReviewCard extends StatelessWidget {
  const _FloatingReviewCard({
    required this.width,
    required this.height,
    required this.rating,
    required this.comment,
    required this.helpful,
  });

  final double width;
  final double height;
  final int rating;
  final String comment;
  final String helpful;

  @override
  Widget build(BuildContext context) {
    final double scale = width / 132;

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: AppColors.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _StarRow(rating: rating, size: 11 * scale),
          SizedBox(height: 8 * scale),
          Expanded(
            child: Text(
              comment,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF62626A),
                fontSize: 10 * scale,
                height: 1.35,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.thumb_up_alt_outlined,
                color: AppColors.textMuted,
                size: 10 * scale,
              ),
              SizedBox(width: 4 * scale),
              Expanded(
                child: Text(
                  helpful,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 7 * scale,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.size});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: index < rating ? AppColors.primary : AppColors.textSoft,
          size: size,
        );
      }),
    );
  }
}

class _FloatingSignal extends StatelessWidget {
  const _FloatingSignal({
    required this.animation,
    required this.icon,
    required this.size,
    required this.rise,
  });

  final Animation<double> animation;
  final IconData icon;
  final double size;
  final double rise;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 0.46).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, rise),
          end: Offset.zero,
        ).animate(animation),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.14),
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 14,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.primary.withValues(alpha: 0.7),
            size: size * 0.48,
          ),
        ),
      ),
    );
  }
}

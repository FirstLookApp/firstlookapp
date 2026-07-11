import 'dart:math' as math;

import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const Color _onboardingBackground = Color(0xFFFAFAFA);

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _titleAnimation;
  late final Animation<double> _phoneAnimation;
  late final Animation<double> _featuresAnimation;
  late final Animation<double> _ctaAnimation;
  late final List<Animation<double>> _cardAnimations;
  bool _animationStarted = false;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _titleAnimation = _interval(0, 0.34);
    _phoneAnimation = _interval(0.12, 0.64);
    _featuresAnimation = _interval(0.52, 0.86);
    _ctaAnimation = _interval(0.7, 1);
    _cardAnimations = <Animation<double>>[
      _interval(0.28, 0.58),
      _interval(0.36, 0.66),
      _interval(0.44, 0.74),
      _interval(0.52, 0.82),
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

  void _showReviewStep() {
    context.push(RouteNames.onboardingReviewPath);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _onboardingBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxHeight < 790;
            final double heroHeight = compact ? 264 : 366;
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
                      OnboardingFadeSlide(
                        animation: _titleAnimation,
                        offset: 0.05,
                        child: OnboardingHeader(
                          compact: compact,
                          title: l10n.onboardingDiscoverTitle,
                          subtitle: l10n.onboardingDiscoverSubtitle,
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 18),
                      _OnboardingHero(
                        height: heroHeight,
                        phoneAnimation: _phoneAnimation,
                        cardAnimations: _cardAnimations,
                      ),
                      SizedBox(height: compact ? 12 : 18),
                      OnboardingFadeSlide(
                        animation: _featuresAnimation,
                        offset: 0.045,
                        child: OnboardingFeaturePanel(
                          labels: <String>[
                            l10n.onboardingFeatureNewApps,
                            l10n.onboardingFeatureRealReviews,
                            l10n.onboardingFeatureDailyDiscoveries,
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
                              label: l10n.onboardingStart,
                              onPressed: _isCompleting ? null : _showReviewStep,
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
                            const OnboardingPageIndicator(activeIndex: 0),
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

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    required this.compact,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final bool compact;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FirstLookLogo(size: compact ? 25 : 28),
        SizedBox(height: compact ? 12 : 16),
        Text(
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
        SizedBox(height: compact ? 7 : 9),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
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
      ],
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({
    required this.height,
    required this.phoneAnimation,
    required this.cardAnimations,
  });

  final double height;
  final Animation<double> phoneAnimation;
  final List<Animation<double>> cardAnimations;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double phoneHeight = height - 4;
          final double phoneWidth = math.min(width * 0.48, phoneHeight * 0.56);
          final double cardWidth = math.min(116, width * 0.31);
          final double cardHeight = cardWidth * 0.76;
          final double sideInset = math.max(0, (width - 380) / 2);

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              OnboardingFadeSlide(
                animation: phoneAnimation,
                offset: 0.08,
                child: _DiscoverPhoneMockup(
                  width: phoneWidth,
                  height: phoneHeight,
                ),
              ),
              Positioned(
                left: sideInset + 1,
                top: height * 0.18,
                child: _AnimatedFloatingCard(
                  animation: cardAnimations[0],
                  angle: -0.055,
                  child: _FloatingAppCard(
                    width: cardWidth,
                    height: cardHeight,
                    name: 'Focusly',
                    category: 'Productivity',
                    rating: '4.8',
                    icon: Icons.bolt_rounded,
                    iconColor: const Color(0xFF1AA66A),
                    iconBackground: const Color(0xFFE8F8EF),
                  ),
                ),
              ),
              Positioned(
                right: sideInset + 1,
                top: height * 0.13,
                child: _AnimatedFloatingCard(
                  animation: cardAnimations[1],
                  angle: 0.05,
                  child: _FloatingAppCard(
                    width: cardWidth,
                    height: cardHeight,
                    name: 'Nomad',
                    category: 'Travel',
                    rating: '4.7',
                    icon: Icons.explore_rounded,
                    iconColor: const Color(0xFF2774D8),
                    iconBackground: const Color(0xFFEAF2FF),
                  ),
                ),
              ),
              Positioned(
                left: sideInset + 6,
                bottom: height * 0.08,
                child: _AnimatedFloatingCard(
                  animation: cardAnimations[2],
                  angle: 0.045,
                  child: _FloatingAppCard(
                    width: cardWidth,
                    height: cardHeight,
                    name: 'Pulse',
                    category: 'Health',
                    rating: '4.9',
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.primary,
                    iconBackground: AppColors.primarySoft,
                  ),
                ),
              ),
              Positioned(
                right: sideInset + 5,
                bottom: height * 0.13,
                child: _AnimatedFloatingCard(
                  animation: cardAnimations[3],
                  angle: -0.05,
                  child: _FloatingAppCard(
                    width: cardWidth,
                    height: cardHeight,
                    name: 'Frame',
                    category: 'Design',
                    rating: '4.6',
                    icon: Icons.layers_rounded,
                    iconColor: const Color(0xFFB67A08),
                    iconBackground: const Color(0xFFFFF6DC),
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

class _DiscoverPhoneMockup extends StatelessWidget {
  const _DiscoverPhoneMockup({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double scale = width / 176;

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
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              9 * scale,
              7 * scale,
              9 * scale,
              6 * scale,
            ),
            child: Column(
              children: <Widget>[
                _PhoneStatusBar(scale: scale),
                SizedBox(height: 5 * scale),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.grid_view_rounded,
                      color: AppColors.primary,
                      size: 13 * scale,
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
                Expanded(
                  child: Center(
                    child: Container(
                      width: 92 * scale,
                      height: 118 * scale,
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(14 * scale),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.phone_iphone_rounded,
                            color: AppColors.textSoft,
                            size: 25 * scale,
                          ),
                          SizedBox(height: 10 * scale),
                          for (final double factor in <double>[1, .78, .9])
                            FractionallySizedBox(
                              widthFactor: factor,
                              child: Container(
                                height: 5 * scale,
                                margin: EdgeInsets.only(bottom: 6 * scale),
                                decoration: BoxDecoration(
                                  color: AppColors.border,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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

class _PhoneStatusBar extends StatelessWidget {
  const _PhoneStatusBar({required this.scale});

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

class _AnimatedFloatingCard extends StatelessWidget {
  const _AnimatedFloatingCard({
    required this.animation,
    required this.angle,
    required this.child,
  });

  final Animation<double> animation;
  final double angle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
        child: Transform.rotate(angle: angle, child: child),
      ),
    );
  }
}

class _FloatingAppCard extends StatelessWidget {
  const _FloatingAppCard({
    required this.width,
    required this.height,
    required this.name,
    required this.category,
    required this.rating,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final double width;
  final double height;
  final String name;
  final String category;
  final String rating;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final double scale = width / 116;

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge * scale),
        border: Border.all(color: AppColors.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34 * scale,
            height: 34 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(icon, color: iconColor, size: 20 * scale),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 7.5 * scale,
                    fontWeight: FontWeight.w600,
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
                      size: 10 * scale,
                    ),
                    SizedBox(width: 2 * scale),
                    Text(
                      rating,
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 7 * scale,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingFeaturePanel extends StatelessWidget {
  const OnboardingFeaturePanel({
    required this.labels,
    this.icons,
    this.iconColors,
    this.showChevrons = false,
    super.key,
  });

  final List<String> labels;
  final List<IconData>? icons;
  final List<Color>? iconColors;
  final bool showChevrons;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: labels.asMap().entries.map((MapEntry<int, String> entry) {
          return Column(
            children: <Widget>[
              if (entry.key > 0)
                const Divider(height: 1, indent: 54, color: AppColors.border),
              SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          icons?[entry.key] ?? Icons.check_rounded,
                          color: iconColors?[entry.key] ?? AppColors.primary,
                          size: 18,
                        ),
                      ),
                      if (showChevrons)
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSoft,
                          size: 20,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class OnboardingFadeSlide extends StatelessWidget {
  const OnboardingFadeSlide({
    required this.animation,
    required this.child,
    this.offset = 0.08,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, offset),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    required this.activeIndex,
    super.key,
  });

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${activeIndex + 1} / 3',
      child: SizedBox(
        height: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (int index) {
            final bool active = index == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOutCubic,
              width: active ? 9 : 7,
              height: active ? 9 : 7,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }
}

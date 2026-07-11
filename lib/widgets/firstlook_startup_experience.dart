import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/firstlook_app_icon.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';

const Color _splashRed = Color(0xFFEF4444);
const Color _splashBlack = Color(0xFF050506);

class FirstLookStartupExperience extends StatefulWidget {
  const FirstLookStartupExperience({
    required this.child,
    required this.isAppReady,
    super.key,
  });

  final Widget child;
  final bool isAppReady;

  @override
  State<FirstLookStartupExperience> createState() =>
      _FirstLookStartupExperienceState();
}

class _FirstLookStartupExperienceState extends State<FirstLookStartupExperience>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _openingComplete = false;
  bool _finishing = false;
  bool _finished = false;

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_playOpening());
    });
  }

  @override
  void didUpdateWidget(FirstLookStartupExperience oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isAppReady && widget.isAppReady) {
      unawaited(_finishIfReady());
    }
  }

  Future<void> _playOpening() async {
    if (_reduceMotion) {
      _controller.value = 0.9;
    } else {
      await _controller.animateTo(
        0.9,
        duration: const Duration(milliseconds: 2100),
        curve: Curves.linear,
      );
    }

    if (!mounted) {
      return;
    }

    _openingComplete = true;
    await _finishIfReady();
  }

  Future<void> _finishIfReady() async {
    if (!_openingComplete || !widget.isAppReady || _finishing || _finished) {
      return;
    }

    _finishing = true;
    if (_reduceMotion) {
      _controller.value = 1;
    } else {
      await _controller.animateTo(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() => _finished = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double progress = _controller.value;
        final double homeReveal = _ease(_phase(progress, 0.9, 1));
        final double overlayOpacity = 1 - _ease(_phase(progress, 0.92, 1));

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Opacity(
              opacity: homeReveal,
              child: Transform.translate(
                offset: Offset(0, ui.lerpDouble(18, 0, homeReveal)!),
                child: child,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: overlayOpacity,
                  child: RepaintBoundary(
                    child: _SplashFrame(progress: progress),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SplashFrame extends StatelessWidget {
  const _SplashFrame({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    final double backgroundProgress = _ease(_phase(progress, 0.6, 0.88));
    final Color targetBackground = AppColors.background(context);
    final Color background =
        Color.lerp(_splashBlack, targetBackground, backgroundProgress)!;
    final Offset heroStart = Offset(size.width / 2, size.height * 0.42);
    final Offset heroTarget = Offset(size.width / 2, padding.top + 35.5);
    final double morphProgress = _ease(_phase(progress, 0.7, 0.9));
    final Offset heroCenter = Offset.lerp(
      heroStart,
      heroTarget,
      morphProgress,
    )!;

    final double appear = _ease(_phase(progress, 0.04, 0.18));
    final double scaleProgress = _ease(_phase(progress, 0.04, 0.4));
    final double heroScale = ui.lerpDouble(0.9, 1, scaleProgress)!;
    final double glowOpacity = _ease(_phase(progress, 0.12, 0.3)) *
        (1 - _ease(_phase(progress, 0.56, 0.72)));
    final double titleOpacity = _ease(_phase(progress, 0.34, 0.48)) *
        (1 - _ease(_phase(progress, 0.66, 0.78)));
    final double taglineOpacity = _ease(_phase(progress, 0.48, 0.62)) *
        (1 - _ease(_phase(progress, 0.68, 0.8)));
    final double transitionBlur = math.sin(math.pi * morphProgress) * 1.2;
    final Color titleColor = Color.lerp(
      Colors.white,
      AppColors.textPrimary(context),
      backgroundProgress,
    )!;
    final Color taglineColor = Color.lerp(
      const Color(0xFFB8B8BE),
      AppColors.textSecondary(context),
      backgroundProgress,
    )!;

    return ExcludeSemantics(
      child: ColoredBox(
        color: background,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomPaint(
              painter: _EnergyTrailsPainter(
                progress: progress,
                target: heroStart,
              ),
            ),
            Positioned(
              left: heroCenter.dx - 120,
              top: heroCenter.dy - 120,
              child: Opacity(
                opacity: glowOpacity,
                child: Transform.scale(
                  scale: ui.lerpDouble(0.88, 1.08, scaleProgress)!,
                  child: const SizedBox.square(
                    dimension: 240,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: <Color>[
                            Color(0x52EF4444),
                            Color(0x1AEF4444),
                            Colors.transparent,
                          ],
                          stops: <double>[0, 0.48, 1],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: heroCenter.dy - 70,
              height: 140,
              child: Center(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: transitionBlur,
                    sigmaY: transitionBlur,
                  ),
                  child: _HeroMark(
                    appear: appear,
                    heroScale: heroScale,
                    morphProgress: morphProgress,
                    shineProgress: _phase(progress, 0.43, 0.59),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: heroStart.dy + 76,
              child: Opacity(
                opacity: titleOpacity,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    ui.lerpDouble(8, 0, _ease(_phase(progress, 0.34, 0.48)))!,
                  ),
                  child: Text(
                    'FIRSTLOOK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: heroStart.dy + 112,
              child: Opacity(
                opacity: taglineOpacity,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    ui.lerpDouble(7, 0, _ease(_phase(progress, 0.48, 0.62)))!,
                  ),
                  child: Text(
                    'Discover.   Share.   Rank.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: taglineColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMark extends StatelessWidget {
  const _HeroMark({
    required this.appear,
    required this.heroScale,
    required this.morphProgress,
    required this.shineProgress,
  });

  final double appear;
  final double heroScale;
  final double morphProgress;
  final double shineProgress;

  @override
  Widget build(BuildContext context) {
    final double iconOpacity =
        appear * (1 - _ease(_phase(morphProgress, 0.22, 0.72)));
    final double wordmarkOpacity =
        appear * _ease(_phase(morphProgress, 0.3, 0.78));
    final double iconSize = ui.lerpDouble(112, 48, morphProgress)!;

    return SizedBox(
      width: 210,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(
            opacity: iconOpacity,
            child: Transform.scale(
              scale: heroScale,
              child: _ShiningAppIcon(
                size: iconSize,
                shineProgress: shineProgress,
              ),
            ),
          ),
          Opacity(
            opacity: wordmarkOpacity,
            child: Transform.scale(
              scale: ui.lerpDouble(1.12, 1, morphProgress)!,
              child: const FirstLookLogo(size: 33),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiningAppIcon extends StatelessWidget {
  const _ShiningAppIcon({
    required this.size,
    required this.shineProgress,
  });

  final double size;
  final double shineProgress;

  @override
  Widget build(BuildContext context) {
    final double shineOpacity = math.sin(math.pi * shineProgress) * 0.42;
    final double shineLeft =
        ui.lerpDouble(-size * 0.72, size * 1.3, _ease(shineProgress))!;

    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            FirstLookAppIcon(size: size),
            Positioned(
              left: shineLeft,
              top: -size * 0.24,
              child: Opacity(
                opacity: shineOpacity,
                child: Transform.rotate(
                  angle: -0.18,
                  child: Container(
                    width: size * 0.22,
                    height: size * 1.5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.transparent,
                          Color(0xCCFFFFFF),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnergyTrailsPainter extends CustomPainter {
  const _EnergyTrailsPainter({
    required this.progress,
    required this.target,
  });

  final double progress;
  final Offset target;

  @override
  void paint(Canvas canvas, Size size) {
    final double visibility = _ease(_phase(progress, 0.16, 0.28)) *
        (1 - _ease(_phase(progress, 0.58, 0.7)));
    if (visibility <= 0) {
      return;
    }

    final List<Path> paths = <Path>[
      _trail(
        size,
        const Offset(0.02, 0.24),
        const Offset(0.2, 0.22),
        const Offset(0.26, 0.38),
      ),
      _trail(
        size,
        const Offset(-0.03, 0.7),
        const Offset(0.18, 0.67),
        const Offset(0.26, 0.51),
      ),
      _trail(
        size,
        const Offset(0.98, 0.2),
        const Offset(0.82, 0.2),
        const Offset(0.74, 0.34),
      ),
      _trail(
        size,
        const Offset(1.04, 0.67),
        const Offset(0.8, 0.66),
        const Offset(0.74, 0.5),
      ),
      _trail(
        size,
        const Offset(0.3, -0.04),
        const Offset(0.31, 0.16),
        const Offset(0.42, 0.28),
      ),
      _trail(
        size,
        const Offset(0.72, 1.04),
        const Offset(0.7, 0.8),
        const Offset(0.59, 0.6),
      ),
    ];

    for (int index = 0; index < paths.length; index++) {
      final double localProgress = _ease(
        _phase(progress, 0.18 + (index * 0.025), 0.54 + (index * 0.018)),
      );
      if (localProgress <= 0) {
        continue;
      }

      final ui.PathMetric metric = paths[index].computeMetrics().first;
      final double head = metric.length * localProgress;
      final double tail = math.max(0, head - (metric.length * 0.16));
      final double pulse = math.sin(math.pi * localProgress);
      final Path segment = metric.extractPath(tail, head);
      final double alpha = visibility * pulse;

      canvas.drawPath(
        segment,
        Paint()
          ..color = _splashRed.withValues(alpha: alpha * 0.62)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..strokeCap = StrokeCap.round,
      );

      final ui.Tangent? tangent = metric.getTangentForOffset(head);
      if (tangent == null) {
        continue;
      }

      canvas
        ..drawCircle(
          tangent.position,
          4.5,
          Paint()
            ..color = _splashRed.withValues(alpha: alpha * 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        )
        ..drawCircle(
          tangent.position,
          1.15,
          Paint()..color = _splashRed.withValues(alpha: alpha * 0.88),
        );
    }
  }

  Path _trail(
    Size size,
    Offset start,
    Offset controlOne,
    Offset controlTwo,
  ) {
    return Path()
      ..moveTo(start.dx * size.width, start.dy * size.height)
      ..cubicTo(
        controlOne.dx * size.width,
        controlOne.dy * size.height,
        controlTwo.dx * size.width,
        controlTwo.dy * size.height,
        target.dx,
        target.dy,
      );
  }

  @override
  bool shouldRepaint(_EnergyTrailsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.target != target;
  }
}

double _phase(double value, double start, double end) {
  return ((value - start) / (end - start)).clamp(0.0, 1.0).toDouble();
}

double _ease(double value) {
  return Curves.easeInOutCubic.transform(value.clamp(0.0, 1.0).toDouble());
}

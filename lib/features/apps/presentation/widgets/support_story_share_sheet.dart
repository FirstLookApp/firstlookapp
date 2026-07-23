import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/services/instagram_story_share_service.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class SupportStoryShareSheet extends StatefulWidget {
  const SupportStoryShareSheet({
    required this.application,
    super.key,
  });

  final ApplicationDetail application;

  static Future<void> show(
    BuildContext context, {
    required ApplicationDetail application,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SupportStoryShareSheet(application: application),
    );
  }

  @override
  State<SupportStoryShareSheet> createState() => _SupportStoryShareSheetState();
}

class _SupportStoryShareSheetState extends State<SupportStoryShareSheet> {
  static const double _storyAspectRatio = 9 / 16;
  static const double _storyPixelRatio = 3;

  final GlobalKey _storyCardKey = GlobalKey();
  bool _isSharing = false;

  String get _iconPath {
    final String? applicationIconPath = widget.application.applicationIconPath;
    if (applicationIconPath != null && applicationIconPath.isNotEmpty) {
      return applicationIconPath;
    }

    return widget.application.screenshots.isEmpty
        ? ''
        : widget.application.screenshots.first;
  }

  String get _backgroundPath => widget.application.screenshots.isEmpty
      ? _iconPath
      : widget.application.screenshots.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheMedia(_iconPath);
      if (_backgroundPath != _iconPath) {
        _precacheMedia(_backgroundPath);
      }
    });
  }

  void _precacheMedia(String path) {
    if (path.isEmpty || !mounted) {
      return;
    }

    precacheImage(NetworkImage(UrlResolver.media(path)), context).catchError(
      (_, __) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.94,
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline(context),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.storyShareTitle,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _isSharing ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip:
                          MaterialLocalizations.of(context).closeButtonTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.storyShareSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 330),
                  child: AspectRatio(
                    aspectRatio: _storyAspectRatio,
                    child: RepaintBoundary(
                      key: _storyCardKey,
                      child: _SupportStoryCard(
                        application: widget.application,
                        iconPath: _iconPath,
                        backgroundPath: _backgroundPath,
                        l10n: l10n,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSharing ? null : _shareToInstagram,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _isSharing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.ios_share_rounded),
                    label: Text(
                      _isSharing
                          ? l10n.storySharePreparing
                          : l10n.storyShareButton,
                      style: const TextStyle(fontWeight: FontWeight.w900),
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

  Future<void> _shareToInstagram() async {
    if (_isSharing) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() => _isSharing = true);

    try {
      await WidgetsBinding.instance.endOfFrame;
      final RenderObject? renderObject =
          _storyCardKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw const InstagramStoryShareException('capture_failed');
      }

      final ui.Image image = await renderObject.toImage(
        pixelRatio: _storyPixelRatio,
      );
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw const InstagramStoryShareException('capture_failed');
      }

      final Directory temporaryDirectory = await getTemporaryDirectory();
      final File storyImage = File(
        '${temporaryDirectory.path}/firstlook-story-${widget.application.id}-${DateTime.now().microsecondsSinceEpoch}.png',
      );
      final Uint8List bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      await storyImage.writeAsBytes(bytes, flush: true);

      await InstagramStoryShareService.instance.shareImage(
        imagePath: storyImage.path,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on InstagramStoryShareException catch (error) {
      if (mounted) {
        _showError(
          error.code == 'instagram_unavailable' ||
                  error.code == 'instagram_not_installed'
              ? l10n.storyShareUnavailable
              : l10n.storyShareFailed,
        );
      }
    } catch (_) {
      if (mounted) {
        _showError(l10n.storyShareFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SupportStoryCard extends StatelessWidget {
  const _SupportStoryCard({
    required this.application,
    required this.iconPath,
    required this.backgroundPath,
    required this.l10n,
  });

  final ApplicationDetail application;
  final String iconPath;
  final String backgroundPath;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (backgroundPath.isNotEmpty)
            Image.network(
              UrlResolver.media(backgroundPath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: AppColors.secondary,
              ),
            )
          else
            const ColoredBox(color: AppColors.secondary),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  const Color(0xFF101114).withValues(alpha: 0.4),
                  const Color(0xFF101114).withValues(alpha: 0.72),
                  const Color(0xFF101114),
                ],
                stops: const <double>[0, 0.52, 1],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Image.asset(
                    'assets/images/firstlook-logo.png',
                    height: 15,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    l10n.storyShareBadge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.storyShareHeadline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    _StoryIcon(path: iconPath),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            application.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            application.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFD4D4DA),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.storyShareSupportCopy,
                  style: const TextStyle(
                    color: Color(0xFFE9E9ED),
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l10n.storyShareCta,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
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

class _StoryIcon extends StatelessWidget {
  const _StoryIcon({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 76,
        height: 76,
        child: path.isEmpty
            ? const ColoredBox(
                color: AppColors.primarySoft,
                child: Icon(Icons.apps_rounded, color: AppColors.primary),
              )
            : Image.network(
                UrlResolver.media(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: AppColors.primarySoft,
                  child: Icon(Icons.apps_rounded, color: AppColors.primary),
                ),
              ),
      ),
    );
  }
}

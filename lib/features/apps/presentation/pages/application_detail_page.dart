import 'dart:async';
import 'dart:math' as math;

import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/core/errors/app_exception.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationDetailPage extends ConsumerStatefulWidget {
  const ApplicationDetailPage({
    required this.applicationId,
    required this.initialPlatform,
    super.key,
  });

  final String applicationId;
  final PlatformType initialPlatform;

  @override
  ConsumerState<ApplicationDetailPage> createState() =>
      _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends ConsumerState<ApplicationDetailPage> {
  final TextEditingController _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ApplicationDetailRequest request = ApplicationDetailRequest(
      id: widget.applicationId,
      platform: widget.initialPlatform,
    );
    final AsyncValue<ApplicationDetail> detail =
        ref.watch(applicationDetailProvider(request));
    final bool isAuthenticated =
        ref.watch(authControllerProvider).valueOrNull?.status ==
            AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: detail.when(
        data: (ApplicationDetail app) {
          final bool canOpenStore = _resolveStoreUrl(app) != null;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                8,
                AppSpacing.screenHorizontal,
                24,
              ),
              children: <Widget>[
                _DetailHeader(
                  app: app,
                  openStoreLabel: l10n.detailOpenStore,
                  createdByLabel: l10n.detailCreatedBy,
                  onOpenStore:
                      canOpenStore ? () => _handleOpenStore(app, l10n) : null,
                  onOwnerTap: app.ownerId.isEmpty || app.ownerUsername.isEmpty
                      ? null
                      : () => context.push(
                            RouteNames.userProfileLocation(
                              app.ownerId,
                              currentPath: GoRouterState.of(context).uri.path,
                            ),
                          ),
                  onLike: () async {
                    if (!isAuthenticated) {
                      context.push(RouteNames.loginPath);
                      return;
                    }

                    await ref
                        .read(firstLookRepositoryProvider)
                        .toggleLike(app.id);
                    ref.invalidate(applicationDetailProvider(request));
                  },
                ),
                const SizedBox(height: 18),
                _ScreenshotRail(screenshots: app.screenshots),
                const SizedBox(height: 22),
                Text(
                  l10n.detailAbout,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  app.description,
                  style: const TextStyle(
                    color: Color(0xFF6D6D74),
                    fontSize: 13,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.detailComments,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final AsyncValue<PagedResult<CommentItem>> comments =
                        ref.watch(commentsProvider(app.id));
                    return comments.when(
                      data: (PagedResult<CommentItem> result) => Column(
                        children: result.items
                            .map<Widget>(
                                (CommentItem item) => _CommentCard(item: item))
                            .toList(),
                      ),
                      error: (Object error, StackTrace stackTrace) =>
                          Text(error.toString()),
                      loading: () => const AppLoadingIndicator(),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _CommentComposer(
                  controller: _comment,
                  onSend: () async {
                    if (!isAuthenticated) {
                      context.push(RouteNames.loginPath);
                      return;
                    }

                    final String content = _comment.text.trim();
                    if (content.isEmpty) {
                      return;
                    }
                    await ref.read(firstLookRepositoryProvider).addComment(
                          id: app.id,
                          content: content,
                        );
                    _comment.clear();
                    ref.invalidate(commentsProvider(app.id));
                  },
                ),
              ],
            ),
          );
        },
        error: (Object error, StackTrace stackTrace) => AppErrorState(
          message: error is AppException
              ? error.message
              : l10n.commonUnexpectedError,
          onRetry: () => ref.invalidate(applicationDetailProvider(request)),
        ),
        loading: () => const AppLoadingIndicator(),
      ),
    );
  }

  Future<void> _handleOpenStore(
    ApplicationDetail app,
    AppLocalizations l10n,
  ) async {
    final String? directUrl = _resolveStoreUrl(app);

    if (directUrl == null || directUrl.isEmpty) {
      _showMessage(l10n.commonUnexpectedError);
      return;
    }

    String destinationUrl = directUrl;
    try {
      final String trackedUrl =
          await ref.read(firstLookRepositoryProvider).trackStoreClick(
                id: app.id,
                platform: widget.initialPlatform,
              );
      ref.invalidate(activeDropProvider);
      ref.invalidate(leaderboardProvider);
      if (trackedUrl.trim().isNotEmpty) {
        destinationUrl = trackedUrl;
      }
    } catch (_) {
      // Opening the verified local URL is still better than blocking the user.
    }

    final Uri? uri = Uri.tryParse(destinationUrl);
    if (uri == null) {
      _showMessage(l10n.commonUnexpectedError);
      return;
    }

    final bool launched =
        await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!launched) {
      _showMessage(l10n.commonUnexpectedError);
      return;
    }
  }

  String? _resolveStoreUrl(ApplicationDetail app) {
    final String? appStoreUrl = _normalizeStoreUrl(app.appStoreUrl);
    final String? googlePlayUrl = _normalizeStoreUrl(app.googlePlayUrl);

    switch (widget.initialPlatform) {
      case PlatformType.ios:
        return appStoreUrl ?? googlePlayUrl;
      case PlatformType.android:
        return googlePlayUrl ?? appStoreUrl;
      case PlatformType.both:
        return appStoreUrl ?? googlePlayUrl;
    }
  }

  String? _normalizeStoreUrl(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.app,
    required this.openStoreLabel,
    required this.createdByLabel,
    required this.onOpenStore,
    required this.onOwnerTap,
    required this.onLike,
  });

  final ApplicationDetail app;
  final String openStoreLabel;
  final String createdByLabel;
  final VoidCallback? onOpenStore;
  final VoidCallback? onOwnerTap;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final String imagePath =
        app.screenshots.isEmpty ? '' : app.screenshots.first;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                app.name,
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onLike,
              icon: Icon(
                app.isLiked ? Icons.favorite : Icons.favorite_border,
                color: AppColors.primary,
                size: 18,
              ),
              label: Text(
                _compactCount(app.likeCount),
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 68,
                height: 68,
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
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    app.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (onOpenStore != null) ...<Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onOpenStore,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                        ),
                        label: Text(
                          openStoreLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (onOwnerTap != null) ...<Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onOwnerTap,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                        ),
                        label: Text(
                          '$createdByLabel @${app.ownerUsername}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      _MetaChip(label: app.category),
                      _MetaChip(label: l10n.dropTab),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ScreenshotRail extends StatelessWidget {
  const _ScreenshotRail({
    required this.screenshots,
  });

  final List<String> screenshots;

  @override
  Widget build(BuildContext context) {
    final List<String> visible =
        screenshots.isEmpty ? <String>[''] : screenshots;

    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          final String path = visible[index];
          return GestureDetector(
            onTap: path.isEmpty
                ? null
                : () => _openGallery(
                      context,
                      screenshots: screenshots,
                      initialPage: index,
                    ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 172,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  border: Border.all(color: AppColors.outline(context)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    path.isEmpty
                        ? const Icon(
                            Icons.phone_iphone,
                            color: AppColors.primary,
                          )
                        : Image.network(
                            UrlResolver.media(path),
                            fit: BoxFit.cover,
                          ),
                    if (path.isNotEmpty)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.open_in_full_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: visible.length,
      ),
    );
  }

  void _openGallery(
    BuildContext context, {
    required List<String> screenshots,
    required int initialPage,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.64),
      builder: (BuildContext dialogContext) => _ScreenshotGalleryDialog(
        screenshots: screenshots,
        initialPage: initialPage,
      ),
    );
  }
}

class _ScreenshotGalleryDialog extends StatefulWidget {
  const _ScreenshotGalleryDialog({
    required this.screenshots,
    required this.initialPage,
  });

  final List<String> screenshots;
  final int initialPage;

  @override
  State<_ScreenshotGalleryDialog> createState() =>
      _ScreenshotGalleryDialogState();
}

class _ScreenshotGalleryDialogState extends State<_ScreenshotGalleryDialog> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 72),
      child: SizedBox(
        width: math.min(420, screenSize.width - 40),
        height: math.min(580, screenSize.height * 0.72),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ColoredBox(
            color: const Color(0xFF11131A),
            child: Stack(
              children: <Widget>[
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.screenshots.length,
                  onPageChanged: (int value) {
                    setState(() => _currentPage = value);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final String path = widget.screenshots[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(18, 52, 18, 42),
                      child: Image.network(
                        UrlResolver.media(path),
                        fit: BoxFit.contain,
                        loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) =>
                            const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white70,
                            size: 42,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ),
                if (widget.screenshots.length > 1)
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '${_currentPage + 1} / ${widget.screenshots.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
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

class _CommentCard extends StatelessWidget {
  const _CommentCard({
    required this.item,
  });

  final CommentItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline(context)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.adaptiveShadow(context),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
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
                  item.username.isEmpty
                      ? '?'
                      : item.username.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  item.username,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.content,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Row(
      children: <Widget>[
        Expanded(
          child: AuthTextField(
            controller: controller,
            label: l10n.commentHint,
            hint: l10n.commentHint,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: onSend,
          style: IconButton.styleFrom(backgroundColor: AppColors.primary),
          icon: const Icon(Icons.send_rounded),
        ),
      ],
    );
  }
}

String _compactCount(int value) {
  if (value >= 1000) {
    final double compact = value / 1000;
    return '${compact.toStringAsFixed(compact >= 10 ? 0 : 1)}K';
  }
  return value.toString();
}

import 'dart:async';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.black,
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
                  onOpenStore:
                      canOpenStore ? () => _handleOpenStore(app, l10n) : null,
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
                  style: const TextStyle(
                    color: AppColors.secondary,
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
                  style: const TextStyle(
                    color: AppColors.secondary,
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

    final Uri? uri = Uri.tryParse(directUrl);
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

    unawaited(
      ref.read(firstLookRepositoryProvider).trackStoreClick(
            id: app.id,
            platform: widget.initialPlatform,
          ),
    );
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
    required this.onOpenStore,
    required this.onLike,
  });

  final ApplicationDetail app;
  final String openStoreLabel;
  final VoidCallback? onOpenStore;
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
                style: const TextStyle(
                  color: AppColors.secondary,
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
                style: const TextStyle(
                  color: Colors.black,
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
                    style: const TextStyle(
                      color: Colors.black,
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
        color: AppColors.chipFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.secondary,
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
          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 172,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(18),
              ),
              child: path.isEmpty
                  ? const Icon(Icons.phone_iphone, color: AppColors.primary)
                  : Image.network(UrlResolver.media(path), fit: BoxFit.cover),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: visible.length,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
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
                  style: const TextStyle(
                    color: AppColors.secondary,
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
            style: const TextStyle(
              color: Color(0xFF62626A),
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

import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationDetailPage extends ConsumerStatefulWidget {
  const ApplicationDetailPage({
    required this.applicationId,
    super.key,
  });

  final String applicationId;

  @override
  ConsumerState<ApplicationDetailPage> createState() =>
      _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends ConsumerState<ApplicationDetailPage> {
  final TextEditingController _comment = TextEditingController();
  final TextEditingController _betaEmail = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    _betaEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<ApplicationDetail> detail =
        ref.watch(applicationDetailProvider(widget.applicationId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: detail.when(
        data: (ApplicationDetail app) => SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: <Widget>[
              _DetailHeader(
                app: app,
                onBack: () => Navigator.of(context).maybePop(),
                onLike: () async {
                  await ref
                      .read(firstLookRepositoryProvider)
                      .toggleLike(app.id);
                  ref.invalidate(applicationDetailProvider(app.id));
                },
              ),
              const SizedBox(height: 18),
              if (app.destination ==
                  SubmitDestination.test.apiValue) ...<Widget>[
                _BetaAccessCard(
                  controller: _betaEmail,
                  onSubmit: () async {
                    await ref
                        .read(firstLookRepositoryProvider)
                        .requestBetaAccess(
                          id: app.id,
                          email: _betaEmail.text.trim(),
                        );
                    _betaEmail.clear();
                  },
                ),
                const SizedBox(height: 18),
              ],
              _ScreenshotRail(screenshots: app.screenshots),
              const SizedBox(height: 22),
              Text(
                l10n.detailAbout,
                style: const TextStyle(
                  color: Colors.black,
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
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
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
              if (app.destination !=
                  SubmitDestination.test.apiValue) ...<Widget>[
                const SizedBox(height: 22),
                AuthPrimaryButton(
                  label: l10n.detailOpenStore,
                  onPressed: () async {
                    final String url = await ref
                        .read(firstLookRepositoryProvider)
                        .trackStoreClick(
                          id: app.id,
                          platform: ref.read(selectedPlatformProvider),
                        );
                    if (url.isNotEmpty) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
        error: (Object error, StackTrace stackTrace) => AppErrorState(
          message: error.toString(),
          onRetry: () =>
              ref.invalidate(applicationDetailProvider(widget.applicationId)),
        ),
        loading: () => const AppLoadingIndicator(),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.app,
    required this.onBack,
    required this.onLike,
  });

  final ApplicationDetail app;
  final VoidCallback onBack;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final String imagePath =
        app.screenshots.isEmpty ? '' : app.screenshots.first;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
            Expanded(
              child: Text(
                app.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
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
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      _MetaChip(label: app.category),
                      _MetaChip(
                        label:
                            app.destination == SubmitDestination.test.apiValue
                                ? 'EARLY ACCESS'
                                : 'DROP',
                      ),
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
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BetaAccessCard extends StatelessWidget {
  const _BetaAccessCard({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.verified_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.detailJoinBeta,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: controller,
            label: l10n.authEmailAddressLabel,
            hint: l10n.loginEmailHint,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          AuthPrimaryButton(
            label: l10n.betaAccessRequestButton,
            onPressed: onSubmit,
          ),
        ],
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
              color: AppColors.primarySoft,
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
        color: const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.thumb_up_alt_outlined, size: 14),
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

import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_button.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:firstlook/widgets/app_text_field.dart';
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
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  Expanded(
                    child: Text(
                      app.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await ref
                          .read(firstLookRepositoryProvider)
                          .toggleLike(app.id);
                      ref.invalidate(applicationDetailProvider(app.id));
                    },
                    icon: Icon(
                      app.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ScreenshotRail(screenshots: app.screenshots),
              const SizedBox(height: 18),
              Text(
                app.category,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                app.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                app.description,
                style: const TextStyle(height: 1.45),
              ),
              const SizedBox(height: 18),
              AppButton(
                label: app.destination == SubmitDestination.test.apiValue
                    ? l10n.detailJoinBeta
                    : l10n.detailOpenStore,
                onPressed: () async {
                  if (app.destination == SubmitDestination.test.apiValue) {
                    await _showBetaSheet(context, app);
                    return;
                  }
                  final String url = await ref
                      .read(firstLookRepositoryProvider)
                      .trackStoreClick(
                        id: app.id,
                        platform: ref.read(selectedPlatformProvider),
                      );
                  if (url.isNotEmpty) {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 22),
              Text(l10n.detailComments,
                  style: Theme.of(context).textTheme.titleLarge),
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
              const SizedBox(height: 12),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final AsyncValue<PagedResult<CommentItem>> comments =
                      ref.watch(commentsProvider(app.id));
                  return comments.when(
                    data: (PagedResult<CommentItem> result) => Column(
                      children: result.items
                          .map<Widget>(
                            (CommentItem item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.username),
                              subtitle: Text(item.content),
                            ),
                          )
                          .toList(),
                    ),
                    error: (Object error, StackTrace stackTrace) =>
                        Text(error.toString()),
                    loading: () => const AppLoadingIndicator(),
                  );
                },
              ),
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

  Future<void> _showBetaSheet(
      BuildContext context, ApplicationDetail app) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.large,
            right: AppSpacing.large,
            top: AppSpacing.large,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.large,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppTextField(
                controller: _betaEmail,
                label: l10n.authEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: l10n.detailJoinBeta,
                onPressed: () async {
                  await ref.read(firstLookRepositoryProvider).requestBetaAccess(
                        id: app.id,
                        email: _betaEmail.text.trim(),
                      );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
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
      height: 330,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          final String path = visible[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 178,
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
          child: AppTextField(
            controller: controller,
            label: l10n.commentHint,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: onSend,
          child: Text(l10n.commentSend),
        ),
      ],
    );
  }
}

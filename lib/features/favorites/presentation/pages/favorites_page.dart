import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<PagedResult<ApplicationListItem>> favorites =
        ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(favoritesProvider),
          child: favorites.when(
            data: (PagedResult<ApplicationListItem> result) => ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
              children: <Widget>[
                Text(
                  l10n.favoritesTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 16),
                if (result.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Text(
                      l10n.commonNoData,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  )
                else
                  ...result.items.map(
                    (ApplicationListItem item) => _FavoriteAppCard(
                      item: item,
                      onTap: () => context.push(
                        RouteNames.detailPath.replaceFirst(':id', item.id),
                      ),
                    ),
                  ),
              ],
            ),
            error: (Object error, StackTrace stackTrace) => AppErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(favoritesProvider),
            ),
            loading: () => const AppLoadingIndicator(),
          ),
        ),
      ),
    );
  }
}

class _FavoriteAppCard extends StatelessWidget {
  const _FavoriteAppCard({
    required this.item,
    required this.onTap,
  });

  final ApplicationListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 58,
                height: 58,
                child: item.mainScreenshot.isEmpty
                    ? const ColoredBox(color: AppColors.primarySoft)
                    : Image.network(
                        UrlResolver.media(item.mainScreenshot),
                        fit: BoxFit.cover,
                      ),
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
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.favorite, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:firstlook/widgets/firstlook_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  SubmitDestination _selectedDestination = SubmitDestination.drop;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<PagedResult<ApplicationListItem>> favorites =
        ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(favoritesProvider),
          child: favorites.when(
            data: (PagedResult<ApplicationListItem> result) {
              final List<ApplicationListItem> filtered = result.items
                  .where((ApplicationListItem item) =>
                      item.destination == _selectedDestination.apiValue)
                  .toList(growable: false);

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 92),
                children: <Widget>[
                  const FirstLookAppHeader(),
                  const SizedBox(height: 30),
                  Text(
                    l10n.favoritesTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DestinationFilter(
                    selected: _selectedDestination,
                    onChanged: (SubmitDestination value) =>
                        setState(() => _selectedDestination = value),
                  ),
                  const SizedBox(height: 22),
                  if (filtered.isEmpty)
                    _EmptyFavorites(message: l10n.favoritesEmptyMessage)
                  else
                    ...filtered.map(
                      (ApplicationListItem item) => _FavoriteAppCard(
                        item: item,
                        onTap: () => context.push(
                          RouteNames.detailPath.replaceFirst(':id', item.id),
                        ),
                      ),
                    ),
                ],
              );
            },
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

class _DestinationFilter extends StatelessWidget {
  const _DestinationFilter({
    required this.selected,
    required this.onChanged,
  });

  final SubmitDestination selected;
  final ValueChanged<SubmitDestination> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Row(
      children: SubmitDestination.values.map((SubmitDestination value) {
        final bool isSelected = selected == value;
        final String label =
            value == SubmitDestination.drop ? l10n.dropTab : l10n.testTab;

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ChoiceChip(
            selected: isSelected,
            label: Text(label),
            selectedColor: Colors.black,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            side: BorderSide(
              color: isSelected ? Colors.black : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onSelected: (_) => onChanged(value),
          ),
        );
      }).toList(),
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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFB),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 54,
                height: 54,
                child: item.mainScreenshot.isEmpty
                    ? const ColoredBox(
                        color: AppColors.primarySoft,
                        child: Icon(
                          Icons.apps_rounded,
                          color: AppColors.primary,
                        ),
                      )
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
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.shortDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.star_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 68),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.folder_off_outlined,
            color: Color(0xFFC9C9CF),
            size: 52,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<List<DiscoveryItem>> discovery =
        ref.watch(discoveryProvider);
    final AsyncValue<PagedResult<ApplicationListItem>> list =
        ref.watch(applicationListProvider);
    final SubmitDestination destination =
        ref.watch(selectedDestinationProvider);
    final PlatformType platform = ref.watch(selectedPlatformProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(discoveryProvider);
            ref.invalidate(applicationListProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 96),
            children: <Widget>[
              const FirstLookLogo(size: 16),
              const SizedBox(height: 18),
              _SegmentedPills<SubmitDestination>(
                values: SubmitDestination.values,
                selected: destination,
                label: (SubmitDestination value) =>
                    value == SubmitDestination.drop
                        ? l10n.dropTab
                        : l10n.testTab,
                onChanged: (SubmitDestination value) => ref
                    .read(selectedDestinationProvider.notifier)
                    .state = value,
              ),
              const SizedBox(height: 12),
              _SegmentedPills<PlatformType>(
                values: PlatformType.values,
                selected: platform,
                label: (PlatformType value) => switch (value) {
                  PlatformType.ios => l10n.iosTab,
                  PlatformType.android => l10n.androidTab,
                  PlatformType.both => l10n.allPlatformsTab,
                },
                onChanged: (PlatformType value) =>
                    ref.read(selectedPlatformProvider.notifier).state = value,
              ),
              const SizedBox(height: 18),
              Text(
                l10n.discoverTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 14),
              discovery.when(
                data: (List<DiscoveryItem> items) => Column(
                  children: items
                      .map(
                        (DiscoveryItem item) => _ApplicationCard(
                          title: item.name,
                          subtitle: item.shortDescription,
                          imagePath: item.mainScreenshot,
                          onTap: () => context.push(
                            RouteNames.detailPath.replaceFirst(':id', item.id),
                          ),
                        ),
                      )
                      .toList(),
                ),
                error: (Object error, StackTrace stackTrace) => AppErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(discoveryProvider),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: AppLoadingIndicator(),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.discoverSubtitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              list.when(
                data: (PagedResult<ApplicationListItem> result) => Column(
                  children: result.items
                      .map<Widget>(
                        (ApplicationListItem item) => _CompactAppRow(
                          item: item,
                          onTap: () => context.push(
                            RouteNames.detailPath.replaceFirst(':id', item.id),
                          ),
                        ),
                      )
                      .toList(),
                ),
                error: (Object error, StackTrace stackTrace) =>
                    const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedPills<T> extends StatelessWidget {
  const _SegmentedPills({
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: values
          .map(
            (T value) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: value == selected,
                  label: Center(child: Text(label(value))),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: value == selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => onChanged(value),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imagePath;
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
                child: imagePath.isEmpty
                    ? const ColoredBox(color: AppColors.primarySoft)
                    : Image.network(UrlResolver.media(imagePath),
                        fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.favorite_border, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _CompactAppRow extends StatelessWidget {
  const _CompactAppRow({
    required this.item,
    required this.onTap,
  });

  final ApplicationListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ApplicationCard(
      title: item.name,
      subtitle: item.shortDescription,
      imagePath: item.mainScreenshot,
      onTap: onTap,
    );
  }
}

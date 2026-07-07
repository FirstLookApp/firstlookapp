import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/network/api_envelope.dart';
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(discoveryProvider);
            ref.invalidate(applicationListProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: <Widget>[
              const FirstLookAppHeader(),
              const SizedBox(height: 24),
              _DestinationSwitch(
                selected: destination,
                onChanged: (SubmitDestination value) => ref
                    .read(selectedDestinationProvider.notifier)
                    .state = value,
              ),
              const SizedBox(height: 24),
              _WeeklyBanner(
                title: destination == SubmitDestination.drop
                    ? l10n.discoverTitle
                    : l10n.testDiscoverTitle,
                timer: l10n.discoverBannerTimer,
                badge: l10n.discoverWeekBadge,
              ),
              const SizedBox(height: 22),
              _SectionTitle(title: l10n.discoverSubtitle),
              const SizedBox(height: 12),
              discovery.when(
                data: (List<DiscoveryItem> items) => items.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        children: items.take(3).map(
                          (DiscoveryItem item) {
                            return _ApplicationRow(
                              title: item.name,
                              subtitle: item.shortDescription,
                              imagePath: item.mainScreenshot,
                              buttonLabel: destination == SubmitDestination.drop
                                  ? l10n.discoverReviewButton
                                  : l10n.detailJoinBeta,
                              onTap: () => context.push(
                                'applications/${item.id}?platform=${PlatformType.both.apiValue}',
                              ),
                            );
                          },
                        ).toList(),
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
              list.when(
                data: (PagedResult<ApplicationListItem> result) => Column(
                  children: result.items
                      .map<Widget>(
                        (ApplicationListItem item) => _CompactAppRow(
                          item: item,
                          buttonLabel: destination == SubmitDestination.drop
                              ? l10n.discoverReviewButton
                              : l10n.detailJoinBeta,
                          onTap: () => context.push(
                            'applications/${item.id}?platform=${item.platform}',
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

class _DestinationSwitch extends StatelessWidget {
  const _DestinationSwitch({
    required this.selected,
    required this.onChanged,
  });

  final SubmitDestination selected;
  final ValueChanged<SubmitDestination> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: SubmitDestination.values.map((SubmitDestination value) {
          final bool isSelected = value == selected;
          final String label =
              value == SubmitDestination.drop ? l10n.dropTab : l10n.testTab;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WeeklyBanner extends StatelessWidget {
  const _WeeklyBanner({
    required this.title,
    required this.timer,
    required this.badge,
  });

  final String title;
  final String timer;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 132,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFFFF3F5), Color(0xFFFFD8E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned(
              left: -16,
              top: -18,
              child: _BannerOrb(size: 66, opacity: 0.38),
            ),
            const Positioned(
              right: -18,
              bottom: -22,
              child: _BannerOrb(size: 96, opacity: 0.28),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 25,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.schedule_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        timer,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerOrb extends StatelessWidget {
  const _BannerOrb({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.buttonLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 48,
                height: 48,
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                minimumSize: const Size(60, 34),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                backgroundColor: const Color(0xFFF4F4F6),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(buttonLabel),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.star_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactAppRow extends StatelessWidget {
  const _CompactAppRow({
    required this.item,
    required this.buttonLabel,
    required this.onTap,
  });

  final ApplicationListItem item;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ApplicationRow(
      title: item.name,
      subtitle: item.shortDescription,
      imagePath: item.mainScreenshot,
      buttonLabel: buttonLabel,
      onTap: onTap,
    );
  }
}

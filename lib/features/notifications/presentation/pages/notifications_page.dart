import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<PagedResult<NotificationItem>> notifications =
        ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        surfaceTintColor: AppColors.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(notificationsProvider)
              ..invalidate(unreadNotificationCountProvider);
          },
          child: notifications.when(
            data: (PagedResult<NotificationItem> result) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
                children: <Widget>[
                  _NotificationsTitle(title: l10n.notificationsTitle),
                  const SizedBox(height: 14),
                  if (result.items.isEmpty)
                    _EmptyNotifications(message: l10n.notificationsEmptyMessage)
                  else
                    ...result.items.map(
                      (NotificationItem item) => _NotificationTile(
                        item: item,
                        onTap: () => _openNotification(context, ref, item),
                      ),
                    ),
                ],
              );
            },
            error: (Object error, StackTrace stackTrace) => AppErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(notificationsProvider),
            ),
            loading: () => const AppLoadingIndicator(),
          ),
        ),
      ),
    );
  }

  Future<void> _openNotification(
    BuildContext context,
    WidgetRef ref,
    NotificationItem item,
  ) async {
    if (!item.isRead) {
      await ref.read(firstLookRepositoryProvider).markNotificationRead(item.id);
      ref
        ..invalidate(notificationsProvider)
        ..invalidate(unreadNotificationCountProvider);
    }

    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => _NotificationDetailSheet(
        item: item,
      ),
    );
  }
}

class _NotificationsTitle extends StatelessWidget {
  const _NotificationsTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 21,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 0,
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
  });

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: item.isRead
                    ? AppColors.surface(context)
                    : AppColors.softPrimary(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item.isRead
                      ? AppColors.outline(context)
                      : AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 10,
                    child: item.isRead
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                  ),
                  const _NotificationIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 13,
                            fontWeight:
                                item.isRead ? FontWeight.w800 : FontWeight.w900,
                            height: 1.05,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 11,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary(context),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationDetailSheet extends StatelessWidget {
  const _NotificationDetailSheet({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final DateTime localCreatedAt = item.createdAt.toLocal();
    final String createdAt =
        '${localizations.formatFullDate(localCreatedAt)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(localCreatedAt))}';

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline(context),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _NotificationIcon(size: 34),
            const SizedBox(height: 16),
            Text(
              item.title,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              createdAt,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item.message,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size + 10,
      child: Icon(
        Icons.notifications_none_rounded,
        color: AppColors.primary,
        size: size,
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 70),
      padding: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.outline(context))),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.notifications_off_outlined,
            color: Color(0xFFD6D6DC),
            size: 54,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

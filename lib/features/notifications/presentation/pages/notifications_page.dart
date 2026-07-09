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

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<PagedResult<NotificationItem>> notifications =
        ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(notificationsProvider),
          child: notifications.when(
            data: (PagedResult<NotificationItem> result) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
                children: <Widget>[
                  const FirstLookAppHeader(),
                  const SizedBox(height: 24),
                  _NotificationsTitle(title: l10n.notificationsTitle),
                  const SizedBox(height: 14),
                  if (result.items.isEmpty)
                    _EmptyNotifications(message: l10n.notificationsEmptyMessage)
                  else
                    ...result.items.map(
                      (NotificationItem item) => _NotificationTile(item: item),
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
}

class _NotificationsTitle extends StatelessWidget {
  const _NotificationsTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 21,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 0,
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF4F4F6)),
      ),
      child: Row(
        children: <Widget>[
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
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
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

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 28,
      child: Icon(
        Icons.notifications_none_rounded,
        color: AppColors.primary,
        size: 18,
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
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
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
            style: const TextStyle(
              color: AppColors.textMuted,
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

import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/network/parsers/api_error_parser.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

final selectedPlatformProvider = StateProvider<PlatformType>(
  (Ref ref) => defaultTargetPlatform == TargetPlatform.android
      ? PlatformType.android
      : PlatformType.ios,
);

final activeDropProvider = FutureProvider<ActiveDropBatch?>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).activeDrop(
        platform: ref.watch(selectedPlatformProvider),
      );
});

final dropCategoriesProvider = FutureProvider<List<String>>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).dropCategories();
});

final leaderboardPeriodProvider =
    StateProvider<LeaderboardPeriod>((Ref ref) => LeaderboardPeriod.weekly);

final leaderboardProvider =
    FutureProvider.family<PagedResult<ApplicationListItem>, LeaderboardPeriod>(
        (Ref ref, LeaderboardPeriod period) {
  return ref.watch(firstLookRepositoryProvider).leaderboard(
        platform: ref.watch(selectedPlatformProvider),
        period: period,
      );
});

final applicationDetailProvider =
    FutureProvider.family<ApplicationDetail, ApplicationDetailRequest>(
  (Ref ref, ApplicationDetailRequest request) {
    return ref.watch(firstLookRepositoryProvider).detail(
          id: request.id,
          platform: request.platform,
        );
  },
);

final commentsProvider =
    FutureProvider.family<PagedResult<CommentItem>, String>(
        (Ref ref, String id) {
  return ref.watch(firstLookRepositoryProvider).comments(id);
});

final profileProvider = FutureProvider<UserProfile>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).profile();
});

final publicUserProfileProvider =
    FutureProvider.family<PublicUserProfile, String>((Ref ref, String userId) {
  return ref.watch(firstLookRepositoryProvider).userProfile(userId);
});

final profileAvatarsProvider = FutureProvider<List<AvatarOption>>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).avatars();
});

final favoritesProvider =
    FutureProvider<PagedResult<ApplicationListItem>>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).favorites();
});

final notificationsProvider =
    FutureProvider<PagedResult<NotificationItem>>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).notifications();
});

final unreadNotificationCountProvider = FutureProvider<int>((Ref ref) {
  final AuthStatus? status =
      ref.watch(authControllerProvider).valueOrNull?.status;
  if (status != AuthStatus.authenticated) {
    return 0;
  }

  return ref.watch(firstLookRepositoryProvider).unreadNotificationCount();
});

final profileCommentsProvider =
    FutureProvider<PagedResult<ProfileCommentItem>>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).profileComments();
});

final myApplicationsProvider =
    FutureProvider<PagedResult<ApplicationListItem>>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).myApplications();
});

final submitApplicationControllerProvider = StateNotifierProvider.autoDispose<
    SubmitApplicationController, AsyncValue<String?>>((Ref ref) {
  return SubmitApplicationController(ref);
});

class SubmitApplicationController extends StateNotifier<AsyncValue<String?>> {
  SubmitApplicationController(this._ref)
      : super(const AsyncData<String?>(null));

  final Ref _ref;
  final ApiErrorParser _errorParser = const ApiErrorParser();

  Future<void> submit(SubmitApplicationPayload payload) async {
    state = const AsyncLoading<String?>();

    try {
      final String applicationId = await _ref
          .read(firstLookRepositoryProvider)
          .submitApplication(payload);
      _ref
        ..invalidate(myApplicationsProvider)
        ..invalidate(profileProvider);
      state = AsyncData<String?>(applicationId);
    } catch (error, stackTrace) {
      state = AsyncError<String?>(_errorParser.parse(error), stackTrace);
    }
  }
}

import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDestinationProvider = StateProvider<SubmitDestination>(
  (Ref ref) => SubmitDestination.drop,
);

final selectedPlatformProvider = StateProvider<PlatformType>(
  (Ref ref) => PlatformType.ios,
);

final discoveryProvider = FutureProvider<List<DiscoveryItem>>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).discover(
        destination: ref.watch(selectedDestinationProvider),
        platform: ref.watch(selectedPlatformProvider),
      );
});

final applicationListProvider =
    FutureProvider<PagedResult<ApplicationListItem>>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).listApplications(
        destination: ref.watch(selectedDestinationProvider),
        platform: ref.watch(selectedPlatformProvider),
      );
});

final applicationDetailProvider =
    FutureProvider.family<ApplicationDetail, String>((Ref ref, String id) {
  return ref.watch(firstLookRepositoryProvider).detail(
        id: id,
        platform: ref.watch(selectedPlatformProvider),
      );
});

final commentsProvider =
    FutureProvider.family<PagedResult<CommentItem>, String>(
        (Ref ref, String id) {
  return ref.watch(firstLookRepositoryProvider).comments(id);
});

final profileProvider = FutureProvider<UserProfile>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).profile();
});

final favoritesProvider =
    FutureProvider<PagedResult<ApplicationListItem>>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).favorites();
});

final notificationsProvider =
    FutureProvider<PagedResult<NotificationItem>>((Ref ref) {
  return ref.watch(firstLookRepositoryProvider).notifications();
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

  Future<void> submit(SubmitApplicationPayload payload) async {
    state = const AsyncLoading<String?>();

    state = await AsyncValue.guard<String?>(() async {
      final String applicationId = await _ref
          .read(firstLookRepositoryProvider)
          .submitApplication(payload);
      _ref
        ..invalidate(myApplicationsProvider)
        ..invalidate(profileProvider);

      return applicationId;
    });
  }
}

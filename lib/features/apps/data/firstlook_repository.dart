import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/features/apps/data/firstlook_remote_data_source.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';

class FirstLookRepository {
  const FirstLookRepository({
    required FirstLookRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final FirstLookRemoteDataSource _remoteDataSource;

  Future<List<DiscoveryItem>> discover({
    required SubmitDestination destination,
    required PlatformType platform,
  }) {
    return _remoteDataSource.discover(
      destination: destination,
      platform: platform,
    );
  }

  Future<PagedResult<ApplicationListItem>> listApplications({
    required SubmitDestination destination,
    required PlatformType platform,
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
  }) {
    return _remoteDataSource.listApplications(
      destination: destination,
      platform: platform,
      pageNumber: pageNumber,
      pageSize: pageSize,
      search: search,
    );
  }

  Future<String> submitApplication(SubmitApplicationPayload payload) {
    return _remoteDataSource.submitApplication(payload);
  }

  Future<ApplicationDetail> detail({
    required String id,
    required PlatformType platform,
  }) {
    return _remoteDataSource.detail(id: id, platform: platform);
  }

  Future<PagedResult<CommentItem>> comments(String id) {
    return _remoteDataSource.comments(id);
  }

  Future<void> addComment({
    required String id,
    required String content,
  }) {
    return _remoteDataSource.addComment(id: id, content: content);
  }

  Future<bool> toggleLike(String id) {
    return _remoteDataSource.toggleLike(id);
  }

  Future<String> trackStoreClick({
    required String id,
    required PlatformType platform,
  }) {
    return _remoteDataSource.trackStoreClick(id: id, platform: platform);
  }

  Future<void> requestBetaAccess({
    required String id,
    required String email,
  }) {
    return _remoteDataSource.requestBetaAccess(id: id, email: email);
  }

  Future<UserProfile> profile() {
    return _remoteDataSource.profile();
  }

  Future<PagedResult<ApplicationListItem>> favorites({
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
  }) {
    return _remoteDataSource.favorites(
      pageNumber: pageNumber,
      pageSize: pageSize,
      search: search,
    );
  }

  Future<PagedResult<NotificationItem>> notifications({
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return _remoteDataSource.notifications(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<PagedResult<ApplicationListItem>> myApplications({
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return _remoteDataSource.myApplications(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}

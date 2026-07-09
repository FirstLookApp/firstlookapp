import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/features/apps/data/firstlook_remote_data_source.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';

class FirstLookRepository {
  const FirstLookRepository({
    required FirstLookRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final FirstLookRemoteDataSource _remoteDataSource;

  Future<ActiveDropBatch?> activeDrop({
    required PlatformType platform,
  }) {
    return _remoteDataSource.activeDrop(platform: platform);
  }

  Future<PagedResult<ApplicationListItem>> leaderboard({
    required PlatformType platform,
  }) {
    return _remoteDataSource.leaderboard(platform: platform);
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

  Future<UserProfile> profile() {
    return _remoteDataSource.profile();
  }

  Future<UserProfile> updateProfile({
    required String firstName,
    required String lastName,
    required String biography,
    String? avatarId,
  }) {
    return _remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      biography: biography,
      avatarId: avatarId,
    );
  }

  Future<List<AvatarOption>> avatars() {
    return _remoteDataSource.avatars();
  }

  Future<void> selectAvatar(String avatarId) {
    return _remoteDataSource.selectAvatar(avatarId);
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

  Future<PagedResult<ProfileCommentItem>> profileComments({
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
  }) {
    return _remoteDataSource.profileComments(
      pageNumber: pageNumber,
      pageSize: pageSize,
      search: search,
    );
  }

  Future<PagedResult<UserSearchItem>> searchUsers({
    required String search,
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return _remoteDataSource.searchUsers(
      search: search,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<PublicUserProfile> userProfile(String userId) {
    return _remoteDataSource.userProfile(userId);
  }

  Future<PagedResult<ApplicationListItem>> myApplications({
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
  }) {
    return _remoteDataSource.myApplications(
      pageNumber: pageNumber,
      pageSize: pageSize,
      search: search,
    );
  }
}

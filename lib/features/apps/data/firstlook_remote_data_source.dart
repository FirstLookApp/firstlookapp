import 'package:dio/dio.dart';
import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/network/api_paths.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';

class FirstLookRemoteDataSource {
  const FirstLookRemoteDataSource({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  Future<ActiveDropBatch?> activeDrop({
    required PlatformType platform,
  }) async {
    try {
      final Response<Map<String, dynamic>> response =
          await _dio.get<Map<String, dynamic>>(
        ApiPaths.activeDrop,
        queryParameters: <String, dynamic>{'platform': platform.label},
        options: Options(extra: <String, dynamic>{'requiresAuth': false}),
      );

      final ApiEnvelope<ActiveDropBatch> envelope =
          ApiEnvelope<ActiveDropBatch>.fromJson(
        response.data ?? <String, dynamic>{},
        (Object? json) => ActiveDropBatch.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );

      return envelope.data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }

  Future<PagedResult<ApplicationListItem>> leaderboard({
    required PlatformType platform,
    required LeaderboardPeriod period,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      ApiPaths.leaderboard,
      queryParameters: <String, dynamic>{
        'platform': platform.label,
        'period': period.apiValue,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );
    return ApiEnvelope<PagedResult<ApplicationListItem>>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => PagedResult<ApplicationListItem>.fromJson(
        json,
        ApplicationListItem.fromJson,
      ),
    ).data;
  }

  Future<String> submitApplication(SubmitApplicationPayload payload) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'Name': payload.name,
      'Category': payload.category,
      'Description': payload.description,
      'VideoUrl': payload.videoUrl,
      'Platform': payload.platform.apiValue,
      'AppStoreUrl': payload.appStoreUrl,
      'GooglePlayUrl': payload.googlePlayUrl,
      'SubmitDestination': payload.destination.apiValue,
      if (payload.screenshotPaths.isNotEmpty)
        'Screenshots': await Future.wait<MultipartFile>(
          payload.screenshotPaths.map(MultipartFile.fromFile),
        ),
    });

    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      ApiPaths.applications,
      data: formData,
    );

    final ApiEnvelope<String> envelope = ApiEnvelope<String>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => json as String? ?? '',
    );

    return envelope.data;
  }

  Future<ApplicationDetail> detail({
    required String id,
    required PlatformType platform,
  }) async {
    try {
      return await _detail(id: id, platform: platform);
    } on DioException catch (error) {
      if (platform == PlatformType.both &&
          (error.response?.statusCode == 404 ||
              error.response?.statusCode == 500)) {
        try {
          return await _detail(id: id, platform: PlatformType.ios);
        } on DioException {
          try {
            return await _detail(id: id, platform: PlatformType.android);
          } on DioException {
            final ApplicationDetail? fallback =
                await _fallbackDetailFromMyApplications(id);
            if (fallback != null) {
              return fallback;
            }
          }
        }
      }

      if (error.response?.statusCode == 404 ||
          error.response?.statusCode == 500) {
        final ApplicationDetail? fallback =
            await _fallbackDetailFromMyApplications(id);
        if (fallback != null) {
          return fallback;
        }
      }

      rethrow;
    }
  }

  Future<ApplicationDetail> _detail({
    required String id,
    required PlatformType platform,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '${ApiPaths.discovery}/$id/detail',
      queryParameters: <String, dynamic>{'platform': platform.label},
    );
    final ApiEnvelope<ApplicationDetail> envelope =
        ApiEnvelope<ApplicationDetail>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => ApplicationDetail.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
      ),
    );

    return envelope.data;
  }

  Future<ApplicationDetail?> _fallbackDetailFromMyApplications(
      String id) async {
    try {
      final PagedResult<ApplicationListItem> mine = await myApplications(
        pageNumber: 1,
        pageSize: 100,
      );
      final ApplicationListItem? item =
          mine.items.cast<ApplicationListItem?>().firstWhere(
                (ApplicationListItem? entry) => entry?.id == id,
                orElse: () => null,
              );

      if (item == null) {
        return null;
      }

      return ApplicationDetail(
        id: item.id,
        name: item.name,
        category: item.category,
        description: item.shortDescription,
        videoUrl: '',
        platform: item.platform,
        appStoreUrl: null,
        googlePlayUrl: null,
        destination: item.destination,
        screenshots: item.mainScreenshot.isEmpty
            ? const <String>[]
            : <String>[item.mainScreenshot],
        isLiked: false,
        likeCount: 0,
        commentCount: 0,
        ownerId: '',
        ownerUsername: '',
      );
    } on DioException {
      return null;
    }
  }

  Future<PagedResult<CommentItem>> comments(String id) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '${ApiPaths.interactions}/$id/comments',
      queryParameters: <String, dynamic>{
        'pageNumber': 1,
        'pageSize': 20,
      },
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );

    final ApiEnvelope<PagedResult<CommentItem>> envelope =
        ApiEnvelope<PagedResult<CommentItem>>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => PagedResult<CommentItem>.fromJson(
        json,
        CommentItem.fromJson,
      ),
    );

    return envelope.data;
  }

  Future<void> addComment({
    required String id,
    required String content,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '${ApiPaths.interactions}/$id/comments',
      data: <String, dynamic>{'content': content},
    );
  }

  Future<bool> toggleLike(String id) async {
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      '${ApiPaths.interactions}/$id/like',
    );

    final ApiEnvelope<bool> envelope = ApiEnvelope<bool>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) =>
          json is Map<String, dynamic> && (json['isLiked'] as bool? ?? false),
    );

    return envelope.data;
  }

  Future<String> trackStoreClick({
    required String id,
    required PlatformType platform,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      '${ApiPaths.interactions}/$id/store-click',
      data: <String, dynamic>{'platform': platform.apiValue},
    );

    final ApiEnvelope<String> envelope = ApiEnvelope<String>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => json is Map<String, dynamic>
          ? json['destinationUrl'] as String? ?? ''
          : '',
    );

    return envelope.data;
  }

  Future<UserProfile> profile() async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(ApiPaths.profileMe);
    final ApiEnvelope<UserProfile> envelope = ApiEnvelope<UserProfile>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => UserProfile.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
      ),
    );

    return envelope.data;
  }

  Future<UserProfile> updateProfile({
    required String firstName,
    required String lastName,
    required String biography,
    String? avatarId,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.put<Map<String, dynamic>>(
      ApiPaths.profileMe,
      data: <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'biography': biography,
        if (avatarId != null) 'avatarId': avatarId,
      },
    );
    return ApiEnvelope<UserProfile>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => UserProfile.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
      ),
    ).data;
  }

  Future<List<AvatarOption>> avatars() async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(ApiPaths.profileAvatars);
    final ApiEnvelope<List<AvatarOption>> envelope =
        ApiEnvelope<List<AvatarOption>>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) {
        final List<Object?> items = json is List<Object?> ? json : <Object?>[];
        return items
            .whereType<Map<String, dynamic>>()
            .map<AvatarOption>(AvatarOption.fromJson)
            .toList(growable: false);
      },
    );

    return envelope.data;
  }

  Future<void> selectAvatar(String avatarId) async {
    await _dio.post<Map<String, dynamic>>(
      ApiPaths.selectAvatar,
      data: <String, dynamic>{'avatarId': avatarId},
    );
  }

  Future<PagedResult<ApplicationListItem>> favorites({
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      ApiPaths.profileFavorites,
      queryParameters: <String, dynamic>{
        'PageNumber': pageNumber,
        'PageSize': pageSize,
        if (search != null && search.isNotEmpty) 'Search': search,
      },
    );

    final ApiEnvelope<PagedResult<ApplicationListItem>> envelope =
        ApiEnvelope<PagedResult<ApplicationListItem>>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => PagedResult<ApplicationListItem>.fromJson(
        json,
        ApplicationListItem.fromJson,
      ),
    );

    return envelope.data;
  }

  Future<PagedResult<NotificationItem>> notifications({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      ApiPaths.profileNotifications,
      queryParameters: <String, dynamic>{
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      },
    );

    final ApiEnvelope<PagedResult<NotificationItem>> envelope =
        ApiEnvelope<PagedResult<NotificationItem>>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => PagedResult<NotificationItem>.fromJson(
        json,
        NotificationItem.fromJson,
      ),
    );

    return envelope.data;
  }

  Future<int> unreadNotificationCount() async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      ApiPaths.profileUnreadNotificationCount,
    );

    return ApiEnvelope<int>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => json as int? ?? 0,
    ).data;
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _dio.post<Map<String, dynamic>>(
      ApiPaths.markNotificationRead(notificationId),
    );
  }

  Future<PagedResult<ProfileCommentItem>> profileComments({
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      ApiPaths.profileComments,
      queryParameters: <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final ApiEnvelope<PagedResult<ProfileCommentItem>> envelope =
        ApiEnvelope<PagedResult<ProfileCommentItem>>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => PagedResult<ProfileCommentItem>.fromJson(
        json,
        ProfileCommentItem.fromJson,
      ),
    );

    return envelope.data;
  }

  Future<PagedResult<UserSearchItem>> searchUsers({
    required String search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      ApiPaths.userSearch,
      queryParameters: <String, dynamic>{
        'PageNumber': pageNumber,
        'PageSize': pageSize,
        'Search': search,
      },
    );

    final ApiEnvelope<PagedResult<UserSearchItem>> envelope =
        ApiEnvelope<PagedResult<UserSearchItem>>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => PagedResult<UserSearchItem>.fromJson(
        json,
        UserSearchItem.fromJson,
      ),
    );

    return envelope.data;
  }

  Future<PagedResult<ApplicationListItem>> searchApplications({
    required String search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      ApiPaths.discoverySearch,
      queryParameters: <String, dynamic>{
        'PageNumber': pageNumber,
        'PageSize': pageSize,
        'Search': search,
      },
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );

    return ApiEnvelope<PagedResult<ApplicationListItem>>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => PagedResult<ApplicationListItem>.fromJson(
        json,
        ApplicationListItem.fromJson,
      ),
    ).data;
  }

  Future<List<String>> dropCategories() async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      ApiPaths.categories,
      queryParameters: const <String, dynamic>{'destination': 1},
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );

    return ApiEnvelope<List<String>>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => (json as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> item) => item['name'] as String? ?? '')
          .where((String name) => name.isNotEmpty)
          .toList(growable: false),
    ).data;
  }

  Future<PublicUserProfile> userProfile(String userId) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(ApiPaths.userProfile(userId));
    final ApiEnvelope<PublicUserProfile> envelope =
        ApiEnvelope<PublicUserProfile>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => PublicUserProfile.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
      ),
    );

    return envelope.data;
  }

  Future<PagedResult<ApplicationListItem>> myApplications({
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      ApiPaths.myApplications,
      queryParameters: <String, dynamic>{
        'PageNumber': pageNumber,
        'PageSize': pageSize,
        if (search != null && search.isNotEmpty) 'Search': search,
      },
    );

    final ApiEnvelope<PagedResult<ApplicationListItem>> envelope =
        ApiEnvelope<PagedResult<ApplicationListItem>>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => PagedResult<ApplicationListItem>.fromJson(
        json,
        ApplicationListItem.fromJson,
      ),
    );

    return envelope.data;
  }
}

import 'package:dio/dio.dart';
import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/network/api_paths.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';

class FirstLookRemoteDataSource {
  const FirstLookRemoteDataSource({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  Future<List<DiscoveryItem>> discover({
    required SubmitDestination destination,
    required PlatformType platform,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '${ApiPaths.discovery}/${destination.label}',
      queryParameters: <String, dynamic>{'platform': platform.label},
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );

    final ApiEnvelope<List<DiscoveryItem>> envelope =
        ApiEnvelope<List<DiscoveryItem>>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) {
        final List<Object?> items = json is List<Object?> ? json : <Object?>[];
        return items
            .whereType<Map<String, dynamic>>()
            .map<DiscoveryItem>(DiscoveryItem.fromJson)
            .toList(growable: false);
      },
    );

    return envelope.data;
  }

  Future<PagedResult<ApplicationListItem>> listApplications({
    required SubmitDestination destination,
    required PlatformType platform,
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '${ApiPaths.discovery}/${destination.label}/list',
      queryParameters: <String, dynamic>{
        'platform': platform.label,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
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
        final PagedResult<ApplicationListItem> fallback =
            await listApplications(
          destination: SubmitDestination.drop,
          platform: platform,
        );

        if (fallback.items.isEmpty) {
          return null;
        }

        return ActiveDropBatch(
          id: '',
          name: '',
          platform: platform.apiValue,
          plannedStartAt: null,
          publishedAt: null,
          items: fallback.items,
        );
      }

      rethrow;
    }
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
          return _detail(id: id, platform: PlatformType.android);
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
      data: <String, dynamic>{'platform': platform.label},
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );

    final ApiEnvelope<String> envelope = ApiEnvelope<String>.fromJson(
      response.data ?? <String, dynamic>{},
      (Object? json) => json is Map<String, dynamic>
          ? json['destinationUrl'] as String? ?? ''
          : '',
    );

    return envelope.data;
  }

  Future<void> requestBetaAccess({
    required String id,
    required String email,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '${ApiPaths.interactions}/$id/beta-request',
      data: <String, dynamic>{'email': email},
      options: Options(extra: <String, dynamic>{'requiresAuth': false}),
    );
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

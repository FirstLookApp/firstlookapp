enum PlatformType {
  ios(1, 'IOS'),
  android(2, 'Android'),
  both(3, 'Both');

  const PlatformType(this.apiValue, this.label);

  final int apiValue;
  final String label;

  static PlatformType fromApiValue(int value) {
    return PlatformType.values.firstWhere(
      (PlatformType platform) => platform.apiValue == value,
      orElse: () => PlatformType.both,
    );
  }
}

enum SubmitDestination {
  drop(1, 'Drop'),
  test(2, 'Test');

  const SubmitDestination(this.apiValue, this.label);

  final int apiValue;
  final String label;
}

class DiscoveryItem {
  const DiscoveryItem({
    required this.id,
    required this.name,
    required this.mainScreenshot,
    required this.shortDescription,
    required this.score,
  });

  factory DiscoveryItem.fromJson(Map<String, dynamic> json) {
    return DiscoveryItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mainScreenshot: json['mainScreenshot'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }

  final String id;
  final String name;
  final String mainScreenshot;
  final String shortDescription;
  final double score;
}

class ApplicationListItem {
  const ApplicationListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.destination,
    required this.platform,
    required this.mainScreenshot,
    required this.shortDescription,
    required this.score,
  });

  factory ApplicationListItem.fromJson(Map<String, dynamic> json) {
    return ApplicationListItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      destination:
          json['destination'] as int? ?? SubmitDestination.drop.apiValue,
      platform: json['platform'] as int? ?? PlatformType.both.apiValue,
      mainScreenshot: json['mainScreenshot'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }

  final String id;
  final String name;
  final String category;
  final int destination;
  final int platform;
  final String mainScreenshot;
  final String shortDescription;
  final double score;
}

class ActiveDropBatch {
  const ActiveDropBatch({
    required this.id,
    required this.name,
    required this.platform,
    required this.plannedStartAt,
    required this.publishedAt,
    required this.items,
  });

  factory ActiveDropBatch.fromJson(Map<String, dynamic> json) {
    final List<Object?> rawItems = json['items'] is List<Object?>
        ? json['items'] as List<Object?>
        : <Object?>[];

    return ActiveDropBatch(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      platform: json['platform'] as int? ?? PlatformType.both.apiValue,
      plannedStartAt: DateTime.tryParse(
        json['plannedStartAt'] as String? ?? '',
      ),
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map<ApplicationListItem>(ApplicationListItem.fromJson)
          .toList(growable: false),
    );
  }

  final String id;
  final String name;
  final int platform;
  final DateTime? plannedStartAt;
  final DateTime? publishedAt;
  final List<ApplicationListItem> items;
}

class SubmitApplicationPayload {
  const SubmitApplicationPayload({
    required this.name,
    required this.category,
    required this.description,
    required this.videoUrl,
    required this.platform,
    required this.appStoreUrl,
    required this.googlePlayUrl,
    required this.destination,
    required this.screenshotPaths,
  });

  final String name;
  final String category;
  final String description;
  final String videoUrl;
  final PlatformType platform;
  final String appStoreUrl;
  final String googlePlayUrl;
  final SubmitDestination destination;
  final List<String> screenshotPaths;
}

class ApplicationDetailRequest {
  const ApplicationDetailRequest({
    required this.id,
    required this.platform,
  });

  final String id;
  final PlatformType platform;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ApplicationDetailRequest &&
        other.id == id &&
        other.platform == platform;
  }

  @override
  int get hashCode => Object.hash(id, platform);
}

class ApplicationDetail {
  const ApplicationDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.videoUrl,
    required this.platform,
    required this.appStoreUrl,
    required this.googlePlayUrl,
    required this.destination,
    required this.screenshots,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
  });

  factory ApplicationDetail.fromJson(Map<String, dynamic> json) {
    final List<Object?> rawScreenshots = json['screenshots'] is List<Object?>
        ? json['screenshots'] as List<Object?>
        : <Object?>[];

    return ApplicationDetail(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      platform: json['platform'] as int? ?? PlatformType.both.apiValue,
      appStoreUrl: json['appStoreUrl'] as String?,
      googlePlayUrl: json['googlePlayUrl'] as String?,
      destination:
          json['destination'] as int? ?? SubmitDestination.drop.apiValue,
      screenshots: rawScreenshots.whereType<String>().toList(growable: false),
      isLiked: json['isLiked'] as bool? ?? false,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
    );
  }

  final String id;
  final String name;
  final String category;
  final String description;
  final String videoUrl;
  final int platform;
  final String? appStoreUrl;
  final String? googlePlayUrl;
  final int destination;
  final List<String> screenshots;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
}

class CommentItem {
  const CommentItem({
    required this.id,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    return CommentItem(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String username;
  final String content;
  final DateTime createdAt;
}

class ProfileCommentItem {
  const ProfileCommentItem({
    required this.id,
    required this.applicationId,
    required this.applicationName,
    required this.applicationMainScreenshot,
    required this.commenterUsername,
    required this.content,
    required this.createdAt,
    required this.isOwnComment,
    required this.isOnOwnApplication,
  });

  factory ProfileCommentItem.fromJson(Map<String, dynamic> json) {
    return ProfileCommentItem(
      id: json['id'] as String? ?? '',
      applicationId: json['applicationId'] as String? ?? '',
      applicationName: json['applicationName'] as String? ?? '',
      applicationMainScreenshot:
          json['applicationMainScreenshot'] as String? ?? '',
      commenterUsername: json['commenterUsername'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isOwnComment: json['isOwnComment'] as bool? ?? true,
      isOnOwnApplication: json['isOnOwnApplication'] as bool? ?? false,
    );
  }

  final String id;
  final String applicationId;
  final String applicationName;
  final String applicationMainScreenshot;
  final String commenterUsername;
  final String content;
  final DateTime createdAt;
  final bool isOwnComment;
  final bool isOnOwnApplication;
}

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.biography,
    required this.avatarUrl,
    required this.totalReceivedLikes,
    required this.totalReceivedComments,
    required this.totalApplications,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      biography: json['biography'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      totalReceivedLikes: json['totalReceivedLikes'] as int? ?? 0,
      totalReceivedComments: json['totalReceivedComments'] as int? ?? 0,
      totalApplications: json['totalApplications'] as int? ?? 0,
    );
  }

  final String userId;
  final String firstName;
  final String lastName;
  final String username;
  final String biography;
  final String? avatarUrl;
  final int totalReceivedLikes;
  final int totalReceivedComments;
  final int totalApplications;
}

class UserSearchItem {
  const UserSearchItem({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.biography,
    required this.avatarUrl,
    required this.totalApplications,
  });

  factory UserSearchItem.fromJson(Map<String, dynamic> json) {
    return UserSearchItem(
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      biography: json['biography'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      totalApplications: json['totalApplications'] as int? ?? 0,
    );
  }

  final String userId;
  final String username;
  final String fullName;
  final String biography;
  final String? avatarUrl;
  final int totalApplications;
}

class PublicUserProfile {
  const PublicUserProfile({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.biography,
    required this.avatarUrl,
    required this.totalReceivedLikes,
    required this.totalReceivedComments,
    required this.totalApplications,
    required this.applications,
  });

  factory PublicUserProfile.fromJson(Map<String, dynamic> json) {
    final List<Object?> rawApplications = json['applications'] is List<Object?>
        ? json['applications'] as List<Object?>
        : <Object?>[];

    return PublicUserProfile(
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      biography: json['biography'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      totalReceivedLikes: json['totalReceivedLikes'] as int? ?? 0,
      totalReceivedComments: json['totalReceivedComments'] as int? ?? 0,
      totalApplications: json['totalApplications'] as int? ?? 0,
      applications: rawApplications
          .whereType<Map<String, dynamic>>()
          .map<ApplicationListItem>(ApplicationListItem.fromJson)
          .toList(growable: false),
    );
  }

  final String userId;
  final String username;
  final String fullName;
  final String biography;
  final String? avatarUrl;
  final int totalReceivedLikes;
  final int totalReceivedComments;
  final int totalApplications;
  final List<ApplicationListItem> applications;
}

class AvatarOption {
  const AvatarOption({
    required this.id,
    required this.name,
    required this.filePath,
  });

  factory AvatarOption.fromJson(Map<String, dynamic> json) {
    return AvatarOption(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String filePath;
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
}

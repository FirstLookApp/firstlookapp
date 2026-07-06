enum PlatformType {
  ios(1, 'IOS'),
  android(2, 'Android'),
  both(3, 'Both');

  const PlatformType(this.apiValue, this.label);

  final int apiValue;
  final String label;
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

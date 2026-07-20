abstract final class RouteNames {
  static const String login = 'login';
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String onboardingReview = 'onboardingReview';
  static const String onboardingRewards = 'onboardingRewards';
  static const String register = 'register';
  static const String otp = 'otp';
  static const String forgotPassword = 'forgotPassword';
  static const String discover = 'discover';
  static const String leaderboard = 'leaderboard';
  static const String detail = 'detail';
  static const String submit = 'submit';
  static const String favorites = 'favorites';
  static const String profile = 'profile';
  static const String userProfile = 'userProfile';
  static const String notifications = 'notifications';

  static const String splashPath = '/';
  static const String onboardingPath = '/onboarding';
  static const String onboardingReviewPath = '/onboarding/review';
  static const String onboardingRewardsPath = '/onboarding/rewards';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String otpPath = '/otp';
  static const String forgotPasswordPath = '/forgot-password';
  static const String discoverPath = '/discover';
  static const String leaderboardPath = '/leaderboard';
  static const String detailPath = '/applications/:id';
  static const String submitPath = '/submit';
  static const String favoritesPath = '/favorites';
  static const String profilePath = '/profile';
  static const String userProfilePath = '/users/:id';
  static const String notificationsPath = '/notifications';

  static String applicationDetailLocation({
    required String id,
    required int platform,
    String? currentPath,
  }) {
    return '${_shellRootFor(currentPath)}/applications/$id?platform=$platform';
  }

  static String applicationEditLocation({
    required String id,
    required int platform,
    String? currentPath,
  }) {
    return '${_shellRootFor(currentPath)}/applications/$id/edit?platform=$platform';
  }

  static String userProfileLocation(String id, {String? currentPath}) {
    return '${_shellRootFor(currentPath)}/users/$id';
  }

  static String notificationsLocation({String? currentPath}) {
    return '${_shellRootFor(currentPath)}/notifications';
  }

  static String _shellRootFor(String? path) {
    if (path == null || path.isEmpty) {
      return discoverPath;
    }

    if (path.startsWith(submitPath)) {
      return submitPath;
    }

    if (path.startsWith(leaderboardPath)) {
      return leaderboardPath;
    }

    if (path.startsWith(favoritesPath)) {
      return favoritesPath;
    }

    if (path.startsWith(profilePath)) {
      return profilePath;
    }

    return discoverPath;
  }
}

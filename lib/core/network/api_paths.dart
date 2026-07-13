abstract final class ApiPaths {
  static const String register = '/api/auth/register';
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendOtp = '/api/auth/resend-otp';
  static const String login = '/api/auth/login';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String logout = '/api/auth/logout';
  static const String usernameAvailability = '/api/auth/username-availability';
  static const String profileMe = '/api/profile/me';
  static const String profileAvatars = '/api/profile/avatars';
  static const String selectAvatar = '/api/profile/select-avatar';
  static const String profileFavorites = '/api/profile/favorites';
  static const String profileNotifications = '/api/profile/notifications';
  static const String profileUnreadNotificationCount =
      '/api/profile/notifications/unread-count';
  static const String profileComments = '/api/profile/comments';
  static const String applications = '/api/applications';
  static const String myApplications = '/api/applications/mine';
  static const String userSearch = '/api/users/search';
  static const String discovery = '/api/discovery';
  static const String discoverySearch = '/api/discovery/search';
  static const String activeDrop = '/api/discovery/drop/active';
  static const String leaderboard = '/api/discovery/leaderboard';
  static const String interactions = '/api/interactions';

  static String userProfile(String userId) => '/api/users/$userId/profile';

  static String markNotificationRead(String notificationId) =>
      '/api/profile/notifications/$notificationId/read';
}

abstract final class RouteNames {
  static const String login = 'login';
  static const String splash = 'splash';
  static const String register = 'register';
  static const String otp = 'otp';
  static const String forgotPassword = 'forgotPassword';
  static const String discover = 'discover';
  static const String detail = 'detail';
  static const String submit = 'submit';
  static const String favorites = 'favorites';
  static const String profile = 'profile';
  static const String notifications = 'notifications';

  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String otpPath = '/otp';
  static const String forgotPasswordPath = '/forgot-password';
  static const String discoverPath = '/discover';
  static const String detailPath = '/applications/:id';
  static const String submitPath = '/submit';
  static const String favoritesPath = '/favorites';
  static const String profilePath = '/profile';
  static const String notificationsPath = '/notifications';

  static String applicationDetailLocation({
    required String id,
    required int platform,
  }) {
    return '/applications/$id?platform=$platform';
  }
}

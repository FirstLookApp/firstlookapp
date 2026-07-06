import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/presentation/pages/application_detail_page.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:firstlook/features/auth/presentation/pages/login_page.dart';
import 'package:firstlook/features/auth/presentation/pages/otp_page.dart';
import 'package:firstlook/features/auth/presentation/pages/register_page.dart';
import 'package:firstlook/features/auth/presentation/pages/splash_page.dart';
import 'package:firstlook/features/favorites/presentation/pages/favorites_page.dart';
import 'package:firstlook/features/home/presentation/pages/discover_page.dart';
import 'package:firstlook/features/notifications/presentation/pages/notifications_page.dart';
import 'package:firstlook/features/profile/presentation/pages/profile_page.dart';
import 'package:firstlook/features/submit/presentation/pages/submit_page.dart';
import 'package:firstlook/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((Ref ref) {
  final AsyncValue<AuthState> authState = ref.watch(authControllerProvider);
  final RouterRefreshNotifier refreshNotifier = RouterRefreshNotifier();

  ref.listen<AsyncValue<AuthState>>(
    authControllerProvider,
    (_, __) => refreshNotifier.notify(),
  );
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: RouteNames.splashPath,
    debugLogDiagnostics: false,
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAuthenticated =
          authState.valueOrNull?.status == AuthStatus.authenticated;
      final bool isGuestRoute = <String>{
        RouteNames.splashPath,
        RouteNames.loginPath,
        RouteNames.registerPath,
        RouteNames.otpPath,
        RouteNames.forgotPasswordPath,
      }.contains(state.matchedLocation);
      final bool requiresAuth = <String>{
        RouteNames.submitPath,
        RouteNames.favoritesPath,
        RouteNames.profilePath,
        RouteNames.notificationsPath,
      }.contains(state.matchedLocation);

      if (!isAuthenticated && requiresAuth) {
        return RouteNames.loginPath;
      }

      if (isAuthenticated && isGuestRoute) {
        return RouteNames.discoverPath;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.splashPath,
        name: RouteNames.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.registerPath,
        name: RouteNames.register,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.otpPath,
        name: RouteNames.otp,
        builder: (_, GoRouterState state) => OtpPage(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPasswordPath,
        name: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.detailPath,
        name: RouteNames.detail,
        builder: (_, GoRouterState state) => ApplicationDetailPage(
          applicationId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.notificationsPath,
        name: RouteNames.notifications,
        builder: (_, __) => const NotificationsPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.discoverPath,
                name: RouteNames.discover,
                builder: (_, __) => const DiscoverPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.submitPath,
                name: RouteNames.submit,
                builder: (_, __) => const SubmitPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.favoritesPath,
                name: RouteNames.favorites,
                builder: (_, __) => const FavoritesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.profilePath,
                name: RouteNames.profile,
                builder: (_, __) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class RouterRefreshNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
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
import 'package:firstlook/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:firstlook/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:firstlook/features/onboarding/presentation/pages/review_onboarding_page.dart';
import 'package:firstlook/features/onboarding/presentation/pages/reward_onboarding_page.dart';
import 'package:firstlook/features/profile/presentation/pages/profile_page.dart';
import 'package:firstlook/features/profile/presentation/pages/user_profile_preview_page.dart';
import 'package:firstlook/features/submit/presentation/pages/submit_page.dart';
import 'package:firstlook/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((Ref ref) {
  final RouterRefreshNotifier refreshNotifier = RouterRefreshNotifier();

  ref.listen<AsyncValue<AuthState>>(
    authControllerProvider,
    (AsyncValue<AuthState>? previous, AsyncValue<AuthState> next) {
      refreshNotifier.notify();

      final AuthState? previousState = previous?.valueOrNull;
      final AuthState? nextState = next.valueOrNull;
      final String? previousSessionKey = previousState?.session?.email;
      final String? nextSessionKey = nextState?.session?.email;
      final bool loggedOut = nextState?.status == AuthStatus.unauthenticated;
      final bool accountChanged = previousSessionKey != nextSessionKey;

      if (loggedOut || accountChanged) {
        _invalidateUserScopedData(ref);
      }
    },
  );
  ref.listen<bool>(
    onboardingControllerProvider,
    (bool? previous, bool next) => refreshNotifier.notify(),
  );
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: RouteNames.splashPath,
    debugLogDiagnostics: false,
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final AsyncValue<AuthState> authState = ref.read(authControllerProvider);

      if (authState.isLoading) {
        return null;
      }

      final AuthState? currentAuthState = authState.valueOrNull;
      final AuthStatus? status = currentAuthState?.status;
      final bool isAuthenticated = status == AuthStatus.authenticated;
      final bool onboardingCompleted = ref.read(onboardingControllerProvider);
      final bool isOnboardingRoute = <String>{
        RouteNames.onboardingPath,
        RouteNames.onboardingReviewPath,
        RouteNames.onboardingRewardsPath,
      }.contains(state.matchedLocation);
      final bool isAuthRoute = <String>{
        RouteNames.loginPath,
        RouteNames.registerPath,
        RouteNames.otpPath,
        RouteNames.forgotPasswordPath,
      }.contains(state.matchedLocation);

      if (!onboardingCompleted && !isOnboardingRoute) {
        return RouteNames.onboardingPath;
      }

      if (onboardingCompleted && isOnboardingRoute) {
        return RouteNames.discoverPath;
      }

      if (status == AuthStatus.otpRequired &&
          state.matchedLocation != RouteNames.otpPath) {
        final String email = currentAuthState?.pendingEmail ?? '';
        return '${RouteNames.otpPath}?email=${Uri.encodeComponent(email)}';
      }

      if (!isAuthenticated && state.matchedLocation == RouteNames.splashPath) {
        return RouteNames.discoverPath;
      }

      if (!isAuthenticated && _requiresAuthentication(state.uri.path)) {
        return RouteNames.loginPath;
      }

      if (isAuthenticated &&
          (state.matchedLocation == RouteNames.splashPath || isAuthRoute)) {
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
        path: RouteNames.onboardingPath,
        name: RouteNames.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.onboardingReviewPath,
        name: RouteNames.onboardingReview,
        pageBuilder: (_, __) => CustomTransitionPage<void>(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          child: const ReviewOnboardingPage(),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final Animation<double> curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.025),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: RouteNames.onboardingRewardsPath,
        name: RouteNames.onboardingRewards,
        pageBuilder: (_, __) => CustomTransitionPage<void>(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          child: const RewardOnboardingPage(),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final Animation<double> curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.025),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        ),
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
        path: RouteNames.notificationsPath,
        redirect: (_, __) => RouteNames.notificationsLocation(),
      ),
      GoRoute(
        path: RouteNames.detailPath,
        redirect: (_, GoRouterState state) =>
            RouteNames.applicationDetailLocation(
          id: state.pathParameters['id'] ?? '',
          platform: int.tryParse(state.uri.queryParameters['platform'] ?? '') ??
              PlatformType.both.apiValue,
        ),
      ),
      GoRoute(
        path: RouteNames.userProfilePath,
        name: RouteNames.userProfile,
        redirect: (_, GoRouterState state) => RouteNames.userProfileLocation(
          state.pathParameters['id'] ?? '',
        ),
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
                routes: <RouteBase>[
                  _detailRoute(),
                  _userProfileRoute(),
                  _notificationsRoute(),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.leaderboardPath,
                name: RouteNames.leaderboard,
                builder: (_, __) => const LeaderboardPage(),
                routes: <RouteBase>[
                  _detailRoute(),
                  _userProfileRoute(),
                  _notificationsRoute(),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.favoritesPath,
                name: RouteNames.favorites,
                builder: (_, __) => const FavoritesPage(),
                routes: <RouteBase>[
                  _detailRoute(),
                  _userProfileRoute(),
                  _notificationsRoute(),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.submitPath,
                name: RouteNames.submit,
                builder: (_, __) => const SubmitPage(),
                routes: <RouteBase>[
                  _detailRoute(),
                  _userProfileRoute(),
                  _notificationsRoute(),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.profilePath,
                name: RouteNames.profile,
                builder: (_, __) => const ProfilePage(),
                routes: <RouteBase>[
                  _detailRoute(),
                  _userProfileRoute(),
                  _notificationsRoute(),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

bool _requiresAuthentication(String path) {
  return path == RouteNames.submitPath ||
      path.startsWith('${RouteNames.submitPath}/') ||
      path == RouteNames.favoritesPath ||
      path.startsWith('${RouteNames.favoritesPath}/') ||
      path == RouteNames.profilePath ||
      path.startsWith('${RouteNames.profilePath}/') ||
      path == RouteNames.notificationsPath ||
      path.endsWith('/notifications');
}

void _invalidateUserScopedData(Ref ref) {
  ref
    ..invalidate(profileProvider)
    ..invalidate(favoritesProvider)
    ..invalidate(notificationsProvider)
    ..invalidate(myApplicationsProvider);
}

GoRoute _detailRoute() {
  return GoRoute(
    path: 'applications/:id',
    builder: (_, GoRouterState state) => _detailPage(state),
    routes: <RouteBase>[
      GoRoute(
        path: 'edit',
        builder: (_, GoRouterState state) {
          final Object? application = state.extra;
          return application is ApplicationDetail
              ? SubmitPage(applicationToEdit: application)
              : _detailPage(state);
        },
      ),
    ],
  );
}

GoRoute _userProfileRoute() {
  return GoRoute(
    path: 'users/:id',
    builder: (_, GoRouterState state) => UserProfilePreviewPage(
      userId: state.pathParameters['id'] ?? '',
    ),
  );
}

GoRoute _notificationsRoute() {
  return GoRoute(
    path: 'notifications',
    builder: (_, __) => const NotificationsPage(),
  );
}

ApplicationDetailPage _detailPage(GoRouterState state) {
  return ApplicationDetailPage(
    applicationId: state.pathParameters['id'] ?? '',
    initialPlatform: PlatformType.fromApiValue(
      int.tryParse(state.uri.queryParameters['platform'] ?? '') ??
          PlatformType.both.apiValue,
    ),
  );
}

class RouterRefreshNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

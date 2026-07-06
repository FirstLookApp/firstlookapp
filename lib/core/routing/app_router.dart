import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/auth/presentation/pages/login_page.dart';
import 'package:firstlook/features/favorites/presentation/pages/favorites_page.dart';
import 'package:firstlook/features/home/presentation/pages/discover_page.dart';
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
    initialLocation: RouteNames.discoverPath,
    debugLogDiagnostics: false,
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAuthenticated =
          authState.valueOrNull?.status == AuthStatus.authenticated;
      final bool isGuestRoute = state.matchedLocation == RouteNames.loginPath;

      if (!isAuthenticated && !isGuestRoute) {
        return RouteNames.loginPath;
      }

      if (isAuthenticated && isGuestRoute) {
        return RouteNames.discoverPath;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.login,
        builder: (_, __) => const LoginPage(),
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

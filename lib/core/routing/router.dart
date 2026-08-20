import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/presentation/component/custom_bottom_app_bar.dart';
import 'package:meomum/core/routing/go_router_refresh_stream.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community/presentation/screen/community_screen_root.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_screen_root.dart';
import 'package:meomum/feature/home/presentation/screen/home_screen_root.dart';
import 'package:meomum/feature/location_search/presentation/screen/location_search_screen_root.dart';
import 'package:meomum/feature/map/presentation/screen/map_screen_root.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_screen_root.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_screen_root.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((Ref ref) {
  final refreshListenable = ref.watch(goRouterRefreshStreamProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.signIn,
    routes: [
      GoRoute(path: Routes.onBoarding, builder: (_, _) => const Placeholder()),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreenRoot()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CustomBottomAppBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, _) => const HomeScreenRoot(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.community,
                builder: (_, _) => const CommunityScreenRoot(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: Routes.communityWrite,
                    pageBuilder: (_, _) => MaterialPage(
                      fullscreenDialog: true,
                      child: const CommunityWriteScreenRoot(),
                    ),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        path: Routes.communityLocationSearch,
                        builder: (_, _) => const LocationSearchScreenRoot(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.map,
                builder: (_, _) => const MapScreenRoot(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.myPage,
                builder: (_, _) => const MyPageScreenRoot(),
              ),
            ],
          ),
        ],
      ),
    ],
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final isSignedIn = ref.read(authRepositoryProvider).isSignedIn;
      final location = state.matchedLocation;
      final isSignInRoute = location == Routes.signIn;
      final isOnBoardingRoute = location == Routes.onBoarding;
      final isAuthEntryRoute = isSignInRoute || isOnBoardingRoute;

      if (!isSignedIn && !isAuthEntryRoute) {
        return Routes.signIn;
      }

      if (isSignedIn && isSignInRoute) {
        return Routes.home;
      }

      return null;
    },
  );
});

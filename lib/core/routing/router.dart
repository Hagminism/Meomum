import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/domain/enum/auth_session_status.dart';
import 'package:meomum/core/presentation/component/custom_bottom_app_bar.dart';
import 'package:meomum/core/presentation/service/auth_session_controller.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community/presentation/screen/community_screen_root.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_screen_root.dart';
import 'package:meomum/feature/home/presentation/screen/home_screen_root.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_screen_root.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_screen_root.dart';
import 'package:meomum/feature/location_search/presentation/screen/location_search_screen_root.dart';
import 'package:meomum/feature/map/presentation/screen/map_screen_root.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_screen_root.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_screen_root.dart';
import 'package:meomum/feature/on_boarding/feature/on_boarding/presentation/screen/on_boarding_screen_root.dart';
import 'package:meomum/feature/on_boarding/feature/select_region/presentation/screen/select_region_screen_root.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_screen_root.dart';
import 'package:meomum/feature/splash/presentation/screen/splash_screen_root.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((Ref ref) {
  final refreshListenable = ref.watch(authSessionControllerProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, _) => const SplashScreenRoot(),
      ),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreenRoot()),
      GoRoute(
        path: Routes.onBoarding,
        builder: (_, _) => const OnBoardingScreenRoot(),
        routes: [
          GoRoute(
            path: Routes.onBoardingCreateProfile,
            builder: (_, _) => const CreateProfileScreenRoot(),
          ),
          GoRoute(
            path: Routes.onBoardingSelectRegion,
            builder: (_, _) => const SelectRegionScreenRoot(),
          ),
        ],
      ),
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
                routes: [
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: Routes.postDetail,
                    builder: (_, GoRouterState state) {
                      return HomePostDetailScreenRoot(
                        postId: state.pathParameters[Routes.postId]!,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.community,
                builder: (_, GoRouterState state) {
                  final categoryName =
                      state.uri.queryParameters[Routes.communityCategoryQuery];
                  final initialCategory = CommunityCategory.values.firstWhere(
                    (CommunityCategory category) =>
                        category.name == categoryName,
                    orElse: () {
                      return CommunityCategory.free;
                    },
                  );

                  return CommunityScreenRoot(
                    initialCategory: initialCategory,
                  );
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: Routes.postDetail,
                    builder: (_, GoRouterState state) {
                      return CommunityPostDetailScreenRoot(
                        postId: state.pathParameters[Routes.postId]!,
                      );
                    },
                  ),
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
      final authRepository = ref.read(authRepositoryProvider);
      final sessionStatus = authRepository.sessionStatus;
      final location = state.matchedLocation;
      final isSplashRoute = location == Routes.splash;
      final isSignInRoute = location == Routes.signIn;
      final isOnBoardingRoute =
          location == Routes.onBoarding ||
          location.startsWith('${Routes.onBoarding}/');

      if (sessionStatus == AuthSessionStatus.initializing) {
        return isSplashRoute ? null : Routes.splash;
      }

      if (sessionStatus == AuthSessionStatus.error) {
        return isSplashRoute ? null : Routes.splash;
      }

      if (sessionStatus == AuthSessionStatus.signedOut) {
        return isSignInRoute ? null : Routes.signIn;
      }

      if (sessionStatus == AuthSessionStatus.signedIn) {
        final currentUser = authRepository.currentUser;
        final hasSelectedRegion = currentUser?.hasSelectedRegion ?? false;

        if (!hasSelectedRegion && !isOnBoardingRoute) {
          return Routes.onBoarding;
        }

        if (hasSelectedRegion && isOnBoardingRoute) {
          return Routes.home;
        }

        if (isSignInRoute || isSplashRoute) {
          return hasSelectedRegion ? Routes.home : Routes.onBoarding;
        }
      }

      return null;
    },
  );
});

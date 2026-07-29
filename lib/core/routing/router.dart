import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/custom_bottom_app_bar.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/home/presentation/home_screen_root.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_screen_root.dart';

final router = GoRouter(
  initialLocation: Routes.signIn,
  routes: [
    GoRoute(
      path: Routes.onBoarding,
      // builder: (_, _) => OnBoardingScreenRoot(),
    ),
    GoRoute(
      path: Routes.signIn,
      builder: (_, _) => const SignInScreenRoot(),
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
            ),
          ],
        ),
      ],
    ),
  ],
);

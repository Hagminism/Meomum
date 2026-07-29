import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_bar_nav_item.dart';
import 'package:meomum/ui/app_colors.dart';

class CustomBottomAppBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomBottomAppBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.black.withValues(alpha: 0.10),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                AppBarNavItem(
                  navigationShell: navigationShell,
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: '홈',
                ),
                AppBarNavItem(
                  navigationShell: navigationShell,
                  index: 1,
                  icon: Icons.article_outlined,
                  selectedIcon: Icons.article_rounded,
                  label: '커뮤니티',
                ),
                AppBarNavItem(
                  navigationShell: navigationShell,
                  index: 2,
                  icon: Icons.map_outlined,
                  selectedIcon: Icons.map_rounded,
                  label: '지도',
                ),
                AppBarNavItem(
                  navigationShell: navigationShell,
                  index: 3,
                  icon: Icons.cases_outlined,
                  selectedIcon: Icons.cases_rounded,
                  label: '일자리',
                ),
                AppBarNavItem(
                  navigationShell: navigationShell,
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: '마이페이지',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

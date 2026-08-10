import 'dart:ui';

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
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(30.0),
              border: Border(
                top: BorderSide(
                  color: AppColors.black.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
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
                    label: '동네지도',
                  ),
                  AppBarNavItem(
                    navigationShell: navigationShell,
                    index: 3,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: '나의 여행',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

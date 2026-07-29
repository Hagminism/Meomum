import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/ui/app_colors.dart';

class AppBarNavItem extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AppBarNavItem({
    super.key,
    required this.navigationShell,
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  void _onTap() {
    navigationShell.goBranch(
      index,
      initialLocation: navigationShell.currentIndex == index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = navigationShell.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.black.withValues(alpha: 0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  size: 24,
                  color: isSelected
                      ? AppColors.black
                      : AppColors.black.withValues(alpha: 0.40),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  // fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -0.1,
                  color: isSelected
                      ? AppColors.black
                      : AppColors.black.withValues(alpha: 0.40),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

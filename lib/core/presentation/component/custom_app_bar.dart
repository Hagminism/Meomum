import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? titleColor;
  final bool? showSettingsButton;
  final bool? showCloseButton;
  final bool? showBackButton;
  final bool? showMoreButton;
  final double? toolbarHeight;
  final void Function()? onSettingsTap;
  final void Function()? onClosePressed;
  final void Function()? onBackPressed;
  final PopupMenuItemBuilder<Object>? moreItemBuilder;
  final void Function(Object value)? onMoreSelected;

  const CustomAppBar({
    super.key,
    required this.title,
    this.titleColor,
    this.onSettingsTap,
    this.onClosePressed,
    this.showSettingsButton,
    this.showCloseButton,
    this.showBackButton,
    this.showMoreButton,
    this.toolbarHeight,
    this.onBackPressed,
    this.moreItemBuilder,
    this.onMoreSelected,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.homeBackground,
      surfaceTintColor: AppColors.homeBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: toolbarHeight,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (showBackButton == true)
                  IconButton(
                    onPressed: onBackPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    icon: const Icon(Icons.chevron_left_rounded, size: 32),
                    color: AppColors.communityMetaText,
                  ),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showSettingsButton == true)
            IconButton(
              onPressed: onSettingsTap,
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              icon: const Icon(
                Icons.settings,
                size: 24,
                color: Color(0xFF646465),
              ),
            ),
          if (showCloseButton == true)
            IconButton(
              onPressed: onClosePressed,
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              icon: const Icon(
                Icons.close,
                size: 24,
                color: AppColors.black,
              ),
            ),
          if (showMoreButton == true)
            PopupMenuButton<Object>(
              padding: const EdgeInsets.all(8),
              icon: const Icon(Icons.more_vert_rounded),
              color: AppColors.white,
              onSelected: onMoreSelected,
              itemBuilder:
                  moreItemBuilder ?? (_) => const <PopupMenuEntry<Object>>[],
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final bool? showSettingsButton;
  final bool? showCloseButton;
  final void Function()? onSettingsTap;
  final void Function()? onClosePressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.titleColor,
    this.onSettingsTap,
    this.onClosePressed,
    this.showSettingsButton,
    this.showCloseButton,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: (titleColor != null) ? titleColor : AppColors.black,
            ),
          ),
          if (showSettingsButton == true)
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(90),
              child: InkWell(
                onTap: onSettingsTap,
                borderRadius: BorderRadius.circular(90),
                child: const Icon(
                  Icons.settings,
                  size: 24,
                  color: Color(0xFF646465),
                ),
              ),
            ),
          if (showCloseButton == true)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClosePressed,
                child: const Icon(
                  Icons.close,
                  size: 24,
                  color: AppColors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

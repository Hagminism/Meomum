import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final void Function() onTap;
  final bool? showSettingsButton;

  const CustomAppBar({
    super.key,
    required this.onTap,
    required this.title,
    this.showSettingsButton,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF003F00),
            ),
          ),
          if (showSettingsButton == true)
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(90),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(90),
                child: Icon(
                  Icons.settings,
                  size: 24,
                  color: Color(0xFF646465),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

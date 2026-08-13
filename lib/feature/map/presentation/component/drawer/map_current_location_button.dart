import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

/// 지도를 사용자의 현재 위치로 이동시키는 컨트롤을 제공합니다.
class MapCurrentLocationButton extends StatelessWidget {
  final void Function() onTap;

  const MapCurrentLocationButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.gps_fixed,
            size: 32,
            color: AppColors.feedContentText,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class MapSearchBar extends StatelessWidget {
  final void Function() onTap;

  const MapSearchBar({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            offset: Offset(0, 4),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 24,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  '주변 장소 검색',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    color: AppColors.feedContentText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

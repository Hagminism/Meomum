import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityRegionHeader extends StatelessWidget {
  final CommunityRegion region;
  final void Function() onPressed;

  const CommunityRegionHeader({
    super.key,
    required this.region,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 24,
                    color: AppColors.mapCategoryButtonSelected,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${region.upperRegion} ${region.lowerRegion}',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: AppColors.communityLocationText,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.communityLocationText,
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

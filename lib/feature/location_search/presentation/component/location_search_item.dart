import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/ui/app_colors.dart';

class LocationSearchItem extends StatelessWidget {
  final CommunityPlace place;
  final void Function(CommunityPlace) onTap;

  const LocationSearchItem({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(place),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.inputBorder,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.uploadButton,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          place.name,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (place.category.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          place.category,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.feedMetaText,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.roadAddress.isNotEmpty
                        ? place.roadAddress
                        : place.address,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.feedContentText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

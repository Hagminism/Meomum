import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/ui/app_colors.dart';

class SelectedLocationField extends StatelessWidget {
  final CommunityPlace? place;
  final void Function() onTap;
  final void Function() onClear;

  const SelectedLocationField({
    super.key,
    required this.place,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasPlace = place != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.inputBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasPlace ? Icons.location_on : Icons.search,
              size: 20,
              color: hasPlace ? AppColors.uploadButton : AppColors.placeholderText,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasPlace ? place!.name : '위치 검색',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: hasPlace ? FontWeight.w500 : FontWeight.w400,
                  color: hasPlace ? AppColors.black : AppColors.placeholderText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasPlace)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.cancel,
                    size: 18,
                    color: AppColors.hintIcon,
                  ),
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.hintIcon,
              ),
          ],
        ),
      ),
    );
  }
}

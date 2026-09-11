import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class MediaPickerButton extends StatelessWidget {
  final void Function() onTap;

  const MediaPickerButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.inputBorder,
            width: 1,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 32,
              color: AppColors.hintIcon,
            ),
            SizedBox(height: 8),
            Text(
              '사진 보관함에서\n선택해 추가',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.hintIcon,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

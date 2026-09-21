import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class MapSearchRetryButton extends StatelessWidget {
  final void Function() onTap;

  const MapSearchRetryButton({
    super.key,
    required this.onTap,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: '검색 다시 시도',
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.uploadButton,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('다시 시도'),
        ),
      ),
    );
  }
}

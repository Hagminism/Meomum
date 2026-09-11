import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityWriteButton extends StatelessWidget {
  final void Function() onPressed;

  const CommunityWriteButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 60,
            height: 60,
            child: Icon(
              Icons.edit_rounded,
              size: 32,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

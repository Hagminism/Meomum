import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityCommentEditForm extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitting;
  final void Function(String value) onChanged;
  final void Function() onCancel;
  final void Function() onSubmit;

  const CommunityCommentEditForm({
    super.key,
    required this.controller,
    required this.isSubmitting,
    required this.onChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSubmitting
        ? AppColors.divider
        : AppColors.inputBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            autofocus: true,
            enabled: !isSubmitting,
            maxLength: 1000,
            minLines: 1,
            maxLines: 5,
            cursorColor: AppColors.primary,
            onChanged: onChanged,
            style: const TextStyle(
              color: AppColors.communityText,
              fontFamily: 'Pretendard',
              fontSize: 16,
              height: 1.35,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              hintText: '댓글을 수정해주세요',
              hintStyle: const TextStyle(
                color: AppColors.placeholderText,
                fontFamily: 'Pretendard',
                fontSize: 16,
              ),
              counterText: '${controller.text.length}/1000',
              counterStyle: const TextStyle(
                color: AppColors.communityMetaText,
                height: 2.5,
                fontFamily: 'Pretendard',
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              label: '취소',
              foregroundColor: isSubmitting
                  ? AppColors.unselectedItem
                  : AppColors.communityMetaText,
              backgroundColor: Colors.transparent,
              borderColor: isSubmitting
                  ? AppColors.divider
                  : AppColors.inputBorder,
              onTap: isSubmitting ? null : onCancel,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              label: '저장',
              foregroundColor: AppColors.white,
              backgroundColor: isSubmitting
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.primary,
              borderColor: Colors.transparent,
              onTap: isSubmitting ? null : onSubmit,
              showProgress: isSubmitting,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color foregroundColor,
    required Color backgroundColor,
    required Color borderColor,
    required void Function()? onTap,
    bool showProgress = false,
  }) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            key: ValueKey('comment-edit-$label'),
            constraints: const BoxConstraints(minWidth: 64, minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: showProgress
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foregroundColor,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: foregroundColor,
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

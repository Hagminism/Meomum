import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityCommentReplyIndicator extends StatelessWidget {
  final bool enabled;
  final void Function() onCancel;

  const CommunityCommentReplyIndicator({
    super.key,
    required this.enabled,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = enabled ? AppColors.primary : AppColors.hintIcon;

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '답글을 작성하고 있어요.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ),
          Semantics(
            button: true,
            enabled: enabled,
            label: '답글 작성 취소',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? onCancel : null,
                borderRadius: BorderRadius.circular(12),
                splashColor: AppColors.settingsPressedSurface,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Text(
                      '취소',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

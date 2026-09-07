import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_action.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_state.dart';
import 'package:meomum/ui/app_colors.dart';

class HomePostDetailCommentInput extends StatelessWidget {
  final HomePostDetailState state;
  final void Function(HomePostDetailAction action) onAction;

  const HomePostDetailCommentInput({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: () => onAction(const HomePostDetailAction.pickImage()),
              borderRadius: BorderRadius.circular(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: state.commentImage == null
                      ? const Icon(
                          Icons.image_outlined,
                          color: AppColors.hintIcon,
                          size: 24,
                        )
                      : Image.file(
                          File(state.commentImage!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  onChanged: (String value) {
                    onAction(HomePostDetailAction.changeComment(value));
                  },
                  minLines: 1,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: '댓글을 입력해주세요',
                    hintStyle: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      color: AppColors.feedContentText,
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(
                  axis: Axis.horizontal,
                  alignment: Alignment.centerLeft,
                  sizeFactor: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: state.isCommentButtonVisible
                  ? Padding(
                      key: const ValueKey('comment-submit'),
                      padding: const EdgeInsets.only(left: 8),
                      child: FilledButton(
                        onPressed: () => onAction(
                          const HomePostDetailAction.submitComment(),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('작성'),
                      ),
                    )
                  : const SizedBox(key: ValueKey('comment-submit-empty')),
            ),
          ],
        ),
      ),
    );
  }
}

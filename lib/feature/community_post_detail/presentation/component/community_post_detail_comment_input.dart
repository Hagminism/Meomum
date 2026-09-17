import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_action.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_state.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostDetailCommentInput extends StatefulWidget {
  final CommunityPostDetailState state;
  final void Function(CommunityPostDetailAction action) onAction;

  const CommunityPostDetailCommentInput({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  State<CommunityPostDetailCommentInput> createState() =>
      _CommunityPostDetailCommentInputState();
}

class _CommunityPostDetailCommentInputState
    extends State<CommunityPostDetailCommentInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.commentContent);
  }

  @override
  void didUpdateWidget(covariant CommunityPostDetailCommentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final commentContent = widget.state.commentContent;
    if (_controller.text == commentContent) return;
    _controller.value = TextEditingValue(
      text: commentContent,
      selection: TextSelection.collapsed(offset: commentContent.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final onAction = widget.onAction;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.replyParentId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '답글을 작성하고 있어요.',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onAction(
                          CommunityPostDetailAction.changeComment(''),
                        );
                        onAction(
                          CommunityPostDetailAction.replyToComment(
                            state.replyParentId!,
                          ),
                        );
                      },
                      child: const Text('취소'),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => onAction(
                    const CommunityPostDetailAction.pickImage(),
                  ),
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
                      controller: _controller,
                      enabled: !state.isCommentSubmitting,
                      maxLength: 1000,
                      buildCounter:
                          (
                            BuildContext context, {
                            required int currentLength,
                            required bool isFocused,
                            required int? maxLength,
                          }) => null,
                      onChanged: (String value) {
                        onAction(
                          CommunityPostDetailAction.changeComment(value),
                        );
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
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
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return SizeTransition(
                          axis: Axis.horizontal,
                          alignment: Alignment.centerLeft,
                          sizeFactor: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                  child: state.isCommentButtonVisible
                      ? Padding(
                          key: const ValueKey('comment-submit'),
                          padding: const EdgeInsets.only(left: 8),
                          child: FilledButton(
                            onPressed: () => onAction(
                              const CommunityPostDetailAction.submitComment(),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            child: Text(
                              state.replyParentId == null ? '댓글 달기' : '답글 달기',
                            ),
                          ),
                        )
                      : const SizedBox(key: ValueKey('comment-submit-empty')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

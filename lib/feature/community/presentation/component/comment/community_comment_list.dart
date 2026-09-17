import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_comment.dart';
import 'package:meomum/feature/community/presentation/component/post/community_profile_avatar.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityCommentList extends StatefulWidget {
  final List<CommunityComment> comments;
  final String postAuthorId;
  final String? currentUserId;
  final String? focusCommentId;
  final String? replyParentId;
  final String? editingCommentId;
  final String editingContent;
  final void Function(String commentId) onReply;
  final void Function(String commentId) onLike;
  final void Function(String commentId) onEdit;
  final void Function(String commentId) onDelete;
  final void Function(String commentId) onReport;
  final void Function(String content) onEditChanged;
  final void Function() onEditSubmit;
  final void Function() onEditCancel;

  const CommunityCommentList({
    super.key,
    required this.comments,
    required this.postAuthorId,
    required this.currentUserId,
    required this.focusCommentId,
    required this.replyParentId,
    required this.editingCommentId,
    required this.editingContent,
    required this.onReply,
    required this.onLike,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
    required this.onEditChanged,
    required this.onEditSubmit,
    required this.onEditCancel,
  });

  @override
  State<CommunityCommentList> createState() => _CommunityCommentListState();
}

class _CommunityCommentListState extends State<CommunityCommentList> {
  final Map<String, GlobalObjectKey> _commentKeys = {};
  late final TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.editingContent);
    _scheduleFocus();
  }

  @override
  void didUpdateWidget(covariant CommunityCommentList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusCommentId != widget.focusCommentId ||
        oldWidget.comments.length != widget.comments.length) {
      _scheduleFocus();
    }
    if (oldWidget.editingCommentId != widget.editingCommentId ||
        (oldWidget.editingContent != widget.editingContent &&
            _editingController.text != widget.editingContent)) {
      _editingController.value = TextEditingValue(
        text: widget.editingContent,
        selection: TextSelection.collapsed(
          offset: widget.editingContent.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            '아직 댓글이 없어요.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: AppColors.communityMetaText,
            ),
          ),
        ),
      );
    }

    return Column(
      children: widget.comments.map(_buildComment).toList(growable: false),
    );
  }

  Widget _buildComment(CommunityComment comment) {
    final isMine = comment.authorId == widget.currentUserId;
    final isPostAuthor = comment.authorId == widget.postAuthorId;
    final isEditing = widget.editingCommentId == comment.id;
    final isReplyTarget = widget.replyParentId == comment.id;
    final isFocused = widget.focusCommentId == comment.id;
    final leftPadding = comment.isReply ? 44.0 : 16.0;

    return Container(
      key: _commentKeys.putIfAbsent(
        comment.id,
        () => GlobalObjectKey('comment-${comment.id}'),
      ),
      width: double.infinity,
      color: isReplyTarget || isFocused
          ? AppColors.settingsPressedSurface
          : Colors.transparent,
      padding: EdgeInsets.fromLTRB(leftPadding, 12, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunityProfileAvatar(imageUrl: comment.profileImageUrl),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            comment.nickname,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isPostAuthor)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.placeTagBadge,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '작성자',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Text(
                            '${comment.neighborhood} · ${comment.timeLabel}',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              color: AppColors.communityMetaText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!comment.isDeleted)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        onSelected: (String value) {
                          switch (value) {
                            case 'edit':
                              widget.onEdit(comment.id);
                            case 'delete':
                              widget.onDelete(comment.id);
                            case 'report':
                              widget.onReport(comment.id);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            if (isMine)
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('수정'),
                              ),
                            if (isMine)
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('삭제'),
                              ),
                            const PopupMenuItem<String>(
                              value: 'report',
                              child: Text('신고하기'),
                            ),
                          ];
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (comment.isDeleted)
                  const Text(
                    '삭제된 댓글입니다.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: AppColors.communityMetaText,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else if (isEditing)
                  _buildEditField()
                else ...[
                  Text(
                    comment.content,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      height: 1.35,
                      color: AppColors.communityText,
                    ),
                  ),
                  if (comment.imageUrl != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        comment.imageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return const SizedBox.shrink();
                            },
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _CommentActionButton(
                        icon: comment.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        label: '${comment.likeCount}',
                        color: comment.isLiked
                            ? AppColors.primary
                            : AppColors.unselectedItem,
                        onTap: () => widget.onLike(comment.id),
                      ),
                      if (!comment.isReply) ...[
                        const SizedBox(width: 14),
                        _CommentActionButton(
                          icon: Icons.reply_rounded,
                          label: '${comment.replyCount}',
                          color: AppColors.unselectedItem,
                          onTap: () => widget.onReply(comment.id),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          autofocus: true,
          maxLength: 1000,
          minLines: 1,
          maxLines: 5,
          controller: _editingController,
          onChanged: widget.onEditChanged,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: widget.onEditCancel,
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: widget.onEditSubmit,
              child: const Text('저장'),
            ),
          ],
        ),
      ],
    );
  }

  void _scheduleFocus() {
    final focusCommentId = widget.focusCommentId;
    if (focusCommentId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _commentKeys[focusCommentId]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          alignment: 0.2,
        );
      }
    });
  }
}

class _CommentActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final void Function() onTap;

  const _CommentActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

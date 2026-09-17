import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_comment.dart';
import 'package:meomum/feature/community/presentation/component/post/community_profile_avatar.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageDetailCommentList extends StatelessWidget {
  final List<CommunityComment> comments;
  final void Function(CommunityComment comment) onTap;

  const MyPageDetailCommentList({
    super.key,
    required this.comments,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final comment = comments[index];
          return InkWell(
            onTap: () => onTap(comment),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommunityProfileAvatar(imageUrl: comment.profileImageUrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                comment.postTitle.isEmpty
                                    ? '게시글'
                                    : comment.postTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              comment.timeLabel,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                color: AppColors.communityMetaText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          comment.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            color: AppColors.communityText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${comment.nickname} · ${comment.neighborhood}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            color: AppColors.communityMetaText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.unselectedItem,
                  ),
                ],
              ),
            ),
          );
        },
        childCount: comments.length,
      ),
    );
  }
}

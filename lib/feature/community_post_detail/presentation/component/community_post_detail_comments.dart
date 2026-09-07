import 'package:flutter/material.dart';
import 'package:meomum/feature/community/presentation/component/post/community_profile_avatar.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostDetailComments extends StatelessWidget {
  const CommunityPostDetailComments({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _CommunityPostDetailComment(
          nickname: '닉네임',
          time: '1분 전',
          location: '죽도동',
          content: '여기에 댓글 내용 입력할수 있음',
          isAuthor: true,
          isVerified: true,
          likeCount: 2,
          commentCount: 1,
        ),
        _CommunityPostDetailComment(
          nickname: '닉네임',
          time: '1분 전',
          location: '죽도동',
          content: '여기에 댓글 내용 입력할수 있음',
          isIndented: true,
          likeCount: 1,
        ),
      ],
    );
  }
}

class _CommunityPostDetailComment extends StatelessWidget {
  final String nickname;
  final String time;
  final String location;
  final String content;
  final bool isIndented;
  final bool isAuthor;
  final bool isVerified;
  final int likeCount;
  final int? commentCount;

  const _CommunityPostDetailComment({
    required this.nickname,
    required this.time,
    required this.location,
    required this.content,
    this.isIndented = false,
    this.isAuthor = false,
    this.isVerified = false,
    required this.likeCount,
    this.commentCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Padding(
        padding: EdgeInsets.fromLTRB(isIndented ? 32 : 16, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommunityProfileAvatar(imageUrl: null),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                nickname,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isAuthor)
                              Container(
                                height: 24,
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.placeTagBadge,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '작성자',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    height: 1,
                                  ),
                                ),
                              ),
                            if (isVerified)
                              const Icon(
                                Icons.verified_rounded,
                                size: 20,
                                color: Color(0xFF526CFF),
                              ),
                            const SizedBox(width: 4),
                            const SizedBox(
                              width: 2,
                              height: 2,
                              child: ColoredBox(color: Color(0xFFD9D9D9)),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                color: AppColors.feedContentText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_vert_rounded, size: 24),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      color: AppColors.communityMetaText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      color: AppColors.communityText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _CommunityPostDetailCommentAction(
                        icon: Icons.favorite_border_rounded,
                        count: likeCount,
                        color: AppColors.unselectedItem,
                      ),
                      if (commentCount != null) ...[
                        const SizedBox(width: 12),
                        _CommunityPostDetailCommentAction(
                          icon: Icons.chat_bubble_outline_rounded,
                          count: commentCount!,
                          color: AppColors.unselectedItem,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPostDetailCommentAction extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _CommunityPostDetailCommentAction({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

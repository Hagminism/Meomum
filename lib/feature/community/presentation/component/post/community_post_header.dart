import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/presentation/component/post/community_profile_avatar.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostHeader extends StatelessWidget {
  final CommunityPost post;

  const CommunityPostHeader({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CommunityProfileAvatar(imageUrl: post.profileImageUrl),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                          color: AppColors.communityText,
                        ),
                      ),
                    ),
                    if (post.isVerified) ...[
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.verified_rounded,
                        size: 20,
                        color: Color(0xFF526CFF),
                      ),
                    ],
                    const SizedBox(width: 4),
                    Container(
                      width: 2,
                      height: 2,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.timeLabel,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        color: AppColors.communityText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  post.neighborhood,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    color: AppColors.communityMetaText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

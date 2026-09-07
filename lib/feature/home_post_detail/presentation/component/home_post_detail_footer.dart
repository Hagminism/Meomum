import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_tag.dart';
import 'package:meomum/ui/app_colors.dart';

class HomePostDetailFooter extends StatelessWidget {
  final CommunityPost post;
  final void Function() onLike;
  final void Function(BuildContext) onShare;

  const HomePostDetailFooter({
    super.key,
    required this.post,
    required this.onLike,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              height: 1.3,
              letterSpacing: -0.16,
              color: AppColors.communityText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (post.place != null)
                CommunityPostTag(
                  label: post.place!.name,
                  backgroundColor: AppColors.placeTagBadge,
                  icon: Icons.location_on,
                ),
              if (post.place != null) const SizedBox(width: 8),
              CommunityPostTag(
                label: post.category.label,
                backgroundColor: AppColors.communityCategoryBadge,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _HomePostDetailAction(
                    icon: post.isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    count: post.likeCount,
                    color: post.isLiked
                        ? AppColors.primary
                        : AppColors.feedContentText,
                    onTap: onLike,
                  ),
                  const SizedBox(width: 12),
                  _HomePostDetailAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    count: post.commentCount,
                    onTap: () {},
                  ),
                ],
              ),
              Builder(
                builder: (BuildContext shareContext) {
                  return IconButton(
                    onPressed: () => onShare(shareContext),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.ios_share_rounded, size: 24),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomePostDetailAction extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final void Function() onTap;

  const _HomePostDetailAction({
    required this.icon,
    required this.count,
    this.color = AppColors.feedContentText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Row(
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
      ),
    );
  }
}

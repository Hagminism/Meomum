import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_action_button.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_tag.dart';
import 'package:meomum/feature/community/presentation/screen/community_action.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostFooter extends StatelessWidget {
  final CommunityPost post;
  final void Function(CommunityAction) onAction;
  final void Function(CommunityPost, BuildContext) onShare;

  const CommunityPostFooter({
    super.key,
    required this.post,
    required this.onAction,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (post.place != null)
                CommunityPostTag(
                  label: post.place!.name,
                  backgroundColor: AppColors.placeTagBadge,
                  icon: Icons.location_on,
                ),
              CommunityPostTag(
                label: post.category.label,
                backgroundColor: AppColors.communityCategoryBadge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: AppColors.communityText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            post.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: AppColors.communityText,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommunityPostActionButton(
                  icon: post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: '${post.likeCount}',
                  color: post.isLiked
                      ? AppColors.primary
                      : AppColors.feedContentText,
                  onPressed: () {
                    onAction(CommunityAction.toggleLike(post.id));
                  },
                ),
                const SizedBox(width: 12),
                CommunityPostActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.commentCount}',
                  color: AppColors.feedContentText,
                  onPressed: () {
                    onAction(CommunityAction.tapComment(post.id));
                  },
                ),
                const Spacer(),
                Builder(
                  builder: (BuildContext shareContext) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () => onShare(post, shareContext),
                          borderRadius: BorderRadius.circular(8),
                          child: const Icon(
                            Icons.ios_share_rounded,
                            size: 24,
                            color: AppColors.feedContentText,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

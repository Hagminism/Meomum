import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_footer.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_header.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_image_carousel.dart';
import 'package:meomum/feature/community/presentation/screen/community_action.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;
  final int currentImageIndex;
  final void Function(CommunityAction action) onAction;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.currentImageIndex,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.homeBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          CommunityPostHeader(post: post),
          const SizedBox(height: 4),
          if (post.imageUrls.isNotEmpty)
            CommunityPostImageCarousel(
              postId: post.id,
              imageUrls: post.imageUrls,
              currentIndex: currentImageIndex,
              onAction: (int index) {
                onAction(CommunityAction.changeImagePage(post.id, index));
              },
            ),
          CommunityPostFooter(
            post: post,
            onAction: onAction,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.divider.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

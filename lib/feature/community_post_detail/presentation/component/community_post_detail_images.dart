import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostDetailImages extends StatelessWidget {
  final CommunityPost post;

  const CommunityPostDetailImages({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(post.imageUrls.length, (int index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == post.imageUrls.length - 1 ? 0 : 8,
          ),
          child: SizedBox(
            height: 282,
            width: double.infinity,
            child: Image.network(
              post.imageUrls[index],
              fit: BoxFit.cover,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return const ColoredBox(
                      color: AppColors.thumbnailPlaceholder,
                      child: Icon(Icons.image_not_supported_outlined),
                    );
                  },
            ),
          ),
        );
      }),
    );
  }
}

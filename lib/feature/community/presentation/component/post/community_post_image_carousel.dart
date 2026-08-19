import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostImageCarousel extends StatelessWidget {
  final String postId;
  final List<String> imageUrls;
  final int currentIndex;
  final void Function(int index) onAction;

  const CommunityPostImageCarousel({
    super.key,
    required this.postId,
    required this.imageUrls,
    required this.currentIndex,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 375 / 332,
          child: PageView.builder(
            itemCount: imageUrls.length,
            onPageChanged: onAction,
            itemBuilder: (BuildContext context, int index) {
              return Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                loadingBuilder:
                    (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const ColoredBox(
                        color: AppColors.thumbnailPlaceholder,
                      );
                    },
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return const ColoredBox(
                        color: AppColors.thumbnailPlaceholder,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.unselectedItem,
                          ),
                        ),
                      );
                    },
              );
            },
          ),
        ),
        if (imageUrls.length > 1)
          SizedBox(
            height: 16,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(imageUrls.length, (int index) {
                  final isSelected = index == currentIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: isSelected ? 12 : 6,
                    height: 6,
                    margin: EdgeInsets.only(
                      right: index == imageUrls.length - 1 ? 0 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.mapCategoryButtonSelected
                          : AppColors.unselectedItem.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }
}

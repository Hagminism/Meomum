import 'package:flutter/material.dart';
import 'package:meomum/feature/home/domain/model/home_feed_item.dart';
import 'package:meomum/feature/home/presentation/screen/home_action.dart';
import 'package:meomum/ui/app_colors.dart';

class HomeFeedCard extends StatelessWidget {
  final HomeFeedItem item;
  final void Function(HomeAction) onAction;

  const HomeFeedCard({
    super.key,
    required this.item,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          onAction(HomeAction.tapFeedItem(item.id));
        },
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.feedCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 173 / 123,
                child: item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return ColoredBox(
                                  color: AppColors.unselectedItem,
                                );
                              },
                        ),
                      )
                    : ColoredBox(color: AppColors.unselectedItem),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.location != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: AppColors.feedMetaText,
                          ),
                          Text(
                            item.location!,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.feedMetaText,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      item.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.feedContentText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (item.placeTag != null)
                          _FeedTagBadge(
                            label: item.placeTag!,
                            backgroundColor: AppColors.placeTagBadge,
                          ),
                        _FeedTagBadge(
                          label: item.category,
                          backgroundColor: AppColors.categoryBadge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: AppColors.feedContentText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.likeCount}',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.feedContentText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                          color: AppColors.feedContentText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.commentCount}',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.feedContentText,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.timeLabel,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.feedMetaText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedTagBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;

  const _FeedTagBadge({
    required this.label,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
          height: 1,
        ),
      ),
    );
  }
}

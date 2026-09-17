import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/ui/app_colors.dart';

class MapStoreListItem extends StatelessWidget {
  final CommercialStore store;

  const MapStoreListItem({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final distance = store.distanceMeters;

    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.storefront_outlined,
                color: AppColors.primary,
                size: 22,
                semanticLabel: '매장',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (store.branchName?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          store.branchName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.feedContentText,
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    if (store.address?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          store.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (distance != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    _formatDistance(distance),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDistance(double distanceMeters) {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()}m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
  }
}

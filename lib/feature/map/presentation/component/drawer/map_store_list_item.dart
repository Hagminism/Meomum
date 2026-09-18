import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/ui/app_colors.dart';

class MapStoreListItem extends StatelessWidget {
  final CommercialStore store;
  final void Function()? onTap;

  const MapStoreListItem({
    super.key,
    required this.store,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final distance = store.distanceMeters;
    final address = store.address?.trim();
    final semanticLabel = [
      store.displayName,
      if (address?.isNotEmpty ?? false) address!,
      if (distance != null) '${_formatDistance(distance)} 거리',
    ].join(', ');

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: semanticLabel,
      child: Material(
        color: AppColors.homeBackground,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        store.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      if (address?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              height: 1.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (distance != null)
                  Text(
                    _formatDistance(distance),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
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

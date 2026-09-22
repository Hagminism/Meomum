import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/ui/app_colors.dart';

class MapClusterStorePicker extends StatelessWidget {
  static const double _headerHeight = 48;
  static const double _itemHeight = 60;
  static const double _maxListHeight = 180;

  static double estimatedHeight(int storeCount) {
    return _headerHeight + math.min(_maxListHeight, storeCount * _itemHeight);
  }

  final List<CommercialStore> stores;
  final void Function(CommercialStore store) onStoreSelected;
  final void Function() onDismiss;

  const MapClusterStorePicker({
    super.key,
    required this.stores,
    required this.onStoreSelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final listHeight = math.min(
      _maxListHeight,
      stores.length * _itemHeight,
    );

    return Material(
      color: AppColors.homeBackground,
      elevation: 8,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 228),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
              child: SizedBox(
                height: _headerHeight - 12,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '이 위치의 매장',
                        style: TextStyle(
                          color: AppColors.black,
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${stores.length}곳',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                      ),
                    ),
                    IconButton(
                      onPressed: onDismiss,
                      tooltip: '매장 목록 닫기',
                      icon: const Icon(Icons.close_rounded),
                      iconSize: 18,
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: listHeight,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  final store = stores[index];
                  return _ClusterStoreListItem(
                    store: store,
                    onTap: () => onStoreSelected(store),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClusterStoreListItem extends StatelessWidget {
  final CommercialStore store;
  final void Function() onTap;

  const _ClusterStoreListItem({
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final address = store.address?.trim();

    return Semantics(
      button: true,
      label: [
        store.displayName,
        if (address?.isNotEmpty ?? false) address!,
      ].join(', '),
      child: Material(
        color: AppColors.homeBackground,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: MapClusterStorePicker._itemHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      if (address?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Pretendard',
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (store.distanceMeters != null)
                  Text(
                    _formatDistance(store.distanceMeters!),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
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

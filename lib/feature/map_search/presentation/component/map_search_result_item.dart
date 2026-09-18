import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/ui/app_colors.dart';

class MapSearchResultItem extends StatelessWidget {
  final CommercialStore store;
  final void Function()? onTap;

  const MapSearchResultItem({
    super.key,
    required this.store,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      store.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (store.address?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          store.address!,
                          maxLines: 2,
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
              if (store.industryLargeName?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    store.industryLargeName!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                  semanticLabel: '상세 보기',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

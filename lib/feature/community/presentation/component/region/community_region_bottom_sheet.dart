import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/presentation/component/region/community_region_list_item.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityRegionBottomSheet extends StatefulWidget {
  final List<CommunityRegion> regions;
  final CommunityRegion selectedRegion;
  final void Function() onClose;
  final void Function(CommunityRegion) onConfirm;

  const CommunityRegionBottomSheet({
    super.key,
    required this.regions,
    required this.selectedRegion,
    required this.onClose,
    required this.onConfirm,
  });

  @override
  State<CommunityRegionBottomSheet> createState() =>
      _CommunityRegionBottomSheetState();
}

class _CommunityRegionBottomSheetState
    extends State<CommunityRegionBottomSheet> {
  late String _selectedUpperRegion;
  late CommunityRegion _selectedRegion;

  List<String> get _upperRegions {
    return widget.regions
        .map((CommunityRegion region) => region.upperRegion)
        .toSet()
        .toList(growable: false);
  }

  List<CommunityRegion> get _lowerRegions {
    final lowerRegions = widget.regions
        .where(
          (CommunityRegion region) =>
              region.upperRegion == _selectedUpperRegion,
        )
        .toList();

    lowerRegions.sort(
      (CommunityRegion first, CommunityRegion second) =>
          first.lowerRegion.compareTo(second.lowerRegion),
    );

    return lowerRegions;
  }

  @override
  void initState() {
    super.initState();
    _selectedUpperRegion = widget.selectedRegion.upperRegion;
    _selectedRegion = widget.selectedRegion;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 560,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '둘러볼 지역 선택',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.communityText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.communityText,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 132,
                    child: ColoredBox(
                      color: AppColors.cardBackground,
                      child: ListView.builder(
                        itemCount: _upperRegions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final upperRegion = _upperRegions[index];

                          return CommunityRegionListItem(
                            label: upperRegion,
                            isSelected: upperRegion == _selectedUpperRegion,
                            onPressed: () {
                              _selectUpperRegion(upperRegion);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _lowerRegions.length,
                      itemBuilder: (BuildContext context, int index) {
                        final region = _lowerRegions[index];

                        return CommunityRegionListItem(
                          label: region.lowerRegion,
                          isSelected: region == _selectedRegion,
                          onPressed: () {
                            setState(() {
                              _selectedRegion = region;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    widget.onConfirm(_selectedRegion);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    '${_selectedRegion.upperRegion} '
                    '${_selectedRegion.lowerRegion} 보기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectUpperRegion(String upperRegion) {
    final lowerRegions = widget.regions
        .where(
          (CommunityRegion region) => region.upperRegion == upperRegion,
        )
        .toList();

    lowerRegions.sort(
      (CommunityRegion first, CommunityRegion second) =>
          first.lowerRegion.compareTo(second.lowerRegion),
    );

    if (lowerRegions.isEmpty) {
      return;
    }

    setState(() {
      _selectedUpperRegion = upperRegion;
      _selectedRegion = lowerRegions.first;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/enum/community_job_source.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityJobSourceFilterBar extends StatelessWidget {
  final CommunityJobSource selectedSource;
  final void Function(CommunityJobSource) onSourcePressed;

  const CommunityJobSourceFilterBar({
    super.key,
    required this.selectedSource,
    required this.onSourcePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: CommunityJobSource.values
                .map<Widget>(_buildSegment)
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSegment(CommunityJobSource source) {
    final isSelected = source == selectedSource;

    return Expanded(
      child: Semantics(
        container: true,
        button: true,
        selected: isSelected,
        label: '${source.label} 필터',
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: SizedBox.expand(
            child: Material(
              color: isSelected
                  ? AppColors.mapCategoryButtonSelected
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  onSourcePressed(source);
                },
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Text(
                    source.label,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.communityText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

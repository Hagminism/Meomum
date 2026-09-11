import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityCategoryBottomSheet extends StatelessWidget {
  final List<CommunityCategory> categories;
  final CommunityCategory selectedCategory;
  final void Function() onClose;
  final void Function(CommunityCategory) onSelected;

  const CommunityCategoryBottomSheet({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onClose,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.viewPaddingOf(context).bottom;

    return SizedBox(
      height: 362 + bottomSafeArea,
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '게시판 선택',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.feedContentText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                    icon: const Icon(
                      Icons.close,
                      size: 28,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 2,
            child: ColoredBox(color: Color(0xFFF5F5F6)),
          ),
          for (final category in categories)
            _CategoryListItem(
              label: _labelFor(category),
              onTap: () => onSelected(category),
            ),
          SizedBox(height: bottomSafeArea),
        ],
      ),
    );
  }

  String _labelFor(CommunityCategory category) {
    if (category == CommunityCategory.free) {
      return '자유';
    }
    return category.label;
  }
}

class _CategoryListItem extends StatelessWidget {
  final String label;
  final void Function() onTap;

  const _CategoryListItem({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: InkWell(
        onTap: onTap,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

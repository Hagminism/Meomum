import 'package:flutter/material.dart';
import 'package:meomum/feature/settings/presentation/component/settings_interactive_row.dart';
import 'package:meomum/ui/app_colors.dart';

class SettingsNoticeEntryItem extends StatelessWidget {
  final void Function() onTap;

  const SettingsNoticeEntryItem({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsInteractiveRow(
      semanticLabel: '공지사항',
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      minHeight: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '공지사항',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: AppColors.communityText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: AppColors.settingsChevron,
            ),
          ],
        ),
      ),
    );
  }
}

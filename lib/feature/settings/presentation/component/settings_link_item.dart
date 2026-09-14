import 'package:flutter/material.dart';
import 'package:meomum/feature/settings/presentation/component/settings_interactive_row.dart';
import 'package:meomum/ui/app_colors.dart';

class SettingsLinkItem extends StatelessWidget {
  final String label;
  final void Function() onTap;

  const SettingsLinkItem({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsInteractiveRow(
      semanticLabel: label,
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: AppColors.communityText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              size: 19,
              color: AppColors.settingsChevron,
            ),
          ],
        ),
      ),
    );
  }
}

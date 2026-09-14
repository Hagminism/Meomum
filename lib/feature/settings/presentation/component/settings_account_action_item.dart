import 'package:flutter/material.dart';
import 'package:meomum/feature/settings/presentation/component/settings_interactive_row.dart';
import 'package:meomum/ui/app_colors.dart';

class SettingsAccountActionItem extends StatelessWidget {
  final String label;
  final Color labelColor;
  final String? description;
  final void Function() onTap;

  const SettingsAccountActionItem({
    super.key,
    required this.label,
    required this.labelColor,
    this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsInteractiveRow(
      semanticLabel: label,
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      minHeight: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 12, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: labelColor,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      description!,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        height: 1.35,
                        color: AppColors.settingsContentText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: AppColors.settingsChevron,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meomum/feature/settings_notice/domain/model/settings_notice.dart';
import 'package:meomum/feature/settings/presentation/component/settings_interactive_row.dart';
import 'package:meomum/ui/app_colors.dart';

class SettingsNoticeItem extends StatelessWidget {
  final SettingsNotice notice;
  final bool isExpanded;
  final void Function() onTap;

  const SettingsNoticeItem({
    super.key,
    required this.notice,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return SettingsInteractiveRow(
      semanticLabel: notice.title,
      borderRadius: BorderRadius.circular(8),
      expanded: isExpanded,
      minHeight: 0,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 12, 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title,
                        maxLines: isExpanded ? null : 2,
                        overflow: isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.1,
                          height: 1.45,
                          color: AppColors.communityText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notice.date,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                          color: AppColors.feedMetaText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Transform.rotate(
                    angle: pi / 2,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: AppColors.settingsChevron,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.settingsExpandedSurface,
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Text(
                      notice.content,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.65,
                        color: AppColors.settingsContentText,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

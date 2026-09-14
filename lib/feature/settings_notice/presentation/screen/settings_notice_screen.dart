import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/settings_notice/domain/model/settings_notice.dart';
import 'package:meomum/feature/settings_notice/presentation/component/settings_notice_item.dart';
import 'package:meomum/feature/settings/presentation/component/settings_section_title.dart';
import 'package:meomum/feature/settings_notice/presentation/screen/settings_notice_action.dart';
import 'package:meomum/ui/app_colors.dart';

class SettingsNoticeScreen extends StatelessWidget {
  final List<SettingsNotice> notices;
  final String? expandedNoticeId;
  final void Function(SettingsNoticeAction) onAction;

  const SettingsNoticeScreen({
    super.key,
    required this.notices,
    required this.expandedNoticeId,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 32;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: CustomAppBar(
                  title: '공지사항',
                  showBackButton: true,
                  onBackPressed: () {
                    onAction(const SettingsNoticeAction.tapBack());
                  },
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPadding),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SettingsSectionTitle(title: '공지사항'),
                      _SettingsNoticeGroup(
                        notices: notices,
                        expandedNoticeId: expandedNoticeId,
                        onNoticeTap: (String id) {
                          onAction(
                            SettingsNoticeAction.toggleNotice(id),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsNoticeGroup extends StatelessWidget {
  final List<SettingsNotice> notices;
  final String? expandedNoticeId;
  final void Function(String id) onNoticeTap;

  const _SettingsNoticeGroup({
    required this.notices,
    required this.expandedNoticeId,
    required this.onNoticeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notices.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            '등록된 공지사항이 없어요.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: AppColors.settingsContentText,
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var index = 0; index < notices.length; index++) ...[
            SettingsNoticeItem(
              notice: notices[index],
              isExpanded: expandedNoticeId == notices[index].id,
              onTap: () => onNoticeTap(notices[index].id),
            ),
            if (index < notices.length - 1)
              SizedBox(
                height: 1,
                child: Divider(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

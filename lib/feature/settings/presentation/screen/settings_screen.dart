import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/core/presentation/component/app_loading_overlay.dart';
import 'package:meomum/feature/settings/presentation/component/settings_account_action_item.dart';
import 'package:meomum/feature/settings/presentation/component/settings_link_item.dart';
import 'package:meomum/feature/settings_notice/presentation/component/settings_notice_entry_item.dart';
import 'package:meomum/feature/settings/presentation/component/settings_section_title.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_action.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_state.dart';
import 'package:meomum/ui/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsState state;
  final void Function(SettingsAction) onAction;

  const SettingsScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 32;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: state.isLoading ? false : true,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.homeBackground,
              body: SafeArea(
                bottom: false,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: CustomAppBar(
                        title: '설정',
                        showBackButton: true,
                        onBackPressed: () {
                          onAction(const SettingsAction.tapBack());
                        },
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPadding),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SettingsSectionTitle(
                              title: '공지사항',
                            ),
                            _SettingsGroup(
                              child: SettingsNoticeEntryItem(
                                onTap: () {
                                  onAction(
                                    const SettingsAction.tapNotices(),
                                  );
                                },
                              ),
                            ),
                            const SettingsSectionTitle(title: '약관 및 정책'),
                            _SettingsGroup(
                              child: SettingsLinkItem(
                                label: '개인정보처리방침',
                                onTap: () {
                                  onAction(
                                    const SettingsAction.tapPrivacyPolicy(),
                                  );
                                },
                              ),
                            ),
                            const SettingsSectionTitle(title: '계정 관리'),
                            _SettingsGroup(
                              child: Column(
                                children: [
                                  SettingsAccountActionItem(
                                    label: '로그아웃',
                                    labelColor: AppColors.communityText,
                                    onTap: () {
                                      onAction(
                                        const SettingsAction.tapLogout(),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height: 1,
                                    child: Divider(
                                      color: AppColors.divider.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  SettingsAccountActionItem(
                                    label: '회원 탈퇴',
                                    labelColor: AppColors.snackBarError,
                                    description: '탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.',
                                    onTap: () {
                                      onAction(
                                        const SettingsAction.tapDeleteAccount(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.isLoading) const AppLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final Widget child;

  const _SettingsGroup({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

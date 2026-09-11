import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/community_write/presentation/component/media_picker_button.dart';
import 'package:meomum/feature/community_write/presentation/component/media_preview_list.dart';
import 'package:meomum/feature/report/presentation/component/report_post_summary.dart';
import 'package:meomum/feature/report/presentation/screen/report_action.dart';
import 'package:meomum/feature/report/presentation/screen/report_state.dart';
import 'package:meomum/ui/app_colors.dart';

class ReportScreen extends StatelessWidget {
  final ReportState state;
  final void Function(ReportAction action) onAction;

  const ReportScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: PopScope(
        canPop: !state.isSubmitting,
        child: Scaffold(
          backgroundColor: AppColors.homeBackground,
          body: SafeArea(
            child: Column(
              children: [
                CustomAppBar(
                  title: '신고하기',
                  titleColor: AppColors.feedContentText,
                  showCloseButton: true,
                  onClosePressed: state.isSubmitting
                      ? null
                      : () => onAction(const ReportAction.tapBack()),
                ),
                Expanded(child: _buildBody()),
                if (state.isFormVisible) _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (state.isFetching || (state.post == null && state.loadError == null)) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.loadError != null || state.post == null) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '게시글 정보를 불러오지 못했습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.feedContentText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => onAction(const ReportAction.retryPost()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final post = state.post!;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionLabel('신고 대상 게시글'),
              const SizedBox(height: 8),
              ReportPostSummary(post: post),
              const SizedBox(height: 20),
              _buildSectionLabel('제목', isRequired: true),
              const SizedBox(height: 8),
              _buildInputField(
                hintText: '신고 제목을 입력해주세요',
                initialValue: state.title,
                maxLength: 50,
                onChanged: (String value) => onAction(
                  ReportAction.changeTitle(value),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionLabel('내용', isRequired: true),
              const SizedBox(height: 8),
              _buildInputField(
                hintText: '신고 내용을 입력해주세요',
                initialValue: state.content,
                maxLines: 8,
                height: 180,
                maxLength: 10000,
                onChanged: (String value) => onAction(
                  ReportAction.changeContent(value),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionLabel('사진'),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    MediaPickerButton(
                      onTap: () => onAction(const ReportAction.pickPhotos()),
                    ),
                    if (state.mediaFiles.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      MediaPreviewList(
                        mediaFiles: state.mediaFiles,
                        onRemove: (int index) => onAction(
                          ReportAction.removePhoto(index),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(
    String label, {
    bool isRequired = false,
  }) {
    return Text.rich(
      TextSpan(
        text: label,
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.snackBarError),
            ),
        ],
      ),
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required String initialValue,
    required void Function(String) onChanged,
    required int maxLength,
    int maxLines = 1,
    double? height,
  }) {
    return Container(
      height: height ?? 50,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.placeholderText,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 4,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: state.isSubmitEnabled
              ? () => onAction(const ReportAction.submit())
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.uploadButton,
            disabledBackgroundColor: AppColors.uploadButton.withValues(
              alpha: 0.4,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: state.isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.white,
                  ),
                )
              : const Text(
                  '신고하기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

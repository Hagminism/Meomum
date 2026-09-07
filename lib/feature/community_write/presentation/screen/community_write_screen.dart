import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/community_write/presentation/component/category/community_category_selector_button.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_action.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_state.dart';
import 'package:meomum/feature/community_write/presentation/component/media_picker_button.dart';
import 'package:meomum/feature/community_write/presentation/component/media_preview_list.dart';
import 'package:meomum/feature/community_write/presentation/component/selected_location_field.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityWriteScreen extends StatelessWidget {
  final CommunityWriteState state;
  final void Function(CommunityWriteAction) onAction;

  const CommunityWriteScreen({
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
        canPop: false,
        child: Scaffold(
          backgroundColor: AppColors.writeBackground,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(
                        child: CustomAppBar(
                          title: '새 글 작성',
                          titleColor: Color(0xFF646465),
                          showCloseButton: true,
                          onClosePressed: state.isLoading
                              ? null
                              : () => onAction(
                                  const CommunityWriteAction.tapBack(),
                                ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // 0. 게시할 지역
                            _buildSectionLabel('게시할 지역', isRequired: true),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => onAction(
                                const CommunityWriteAction.tapRegionSelect(),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.inputBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.inputBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${state.selectedRegion.upperRegion} ${state.selectedRegion.lowerRegion}',
                                        style: const TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.hintIcon,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 1. 게시판 카테고리
                            _buildSectionLabel('게시판', isRequired: true),
                            const SizedBox(height: 8),
                            CommunityCategorySelectorButton(
                              selectedCategory: state.category,
                              onTap: () => onAction(
                                const CommunityWriteAction.tapCategorySelect(),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 2. 사진/동영상 추가
                            _buildSectionLabel('사진이나 동영상'),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  MediaPickerButton(
                                    onTap: () => onAction(
                                      const CommunityWriteAction.pickMedia(),
                                    ),
                                  ),
                                  if (state.mediaFiles.isNotEmpty) ...[
                                    const SizedBox(width: 10),
                                    MediaPreviewList(
                                      mediaFiles: state.mediaFiles,
                                      onRemove: (index) {
                                        onAction(
                                          CommunityWriteAction.removeMedia(
                                            index,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 3. 위치 검색
                            _buildSectionLabel('위치'),
                            const SizedBox(height: 8),
                            SelectedLocationField(
                              place: state.selectedPlace,
                              onTap: () {
                                onAction(
                                  const CommunityWriteAction.tapLocationSearch(),
                                );
                              },
                              onClear: () {
                                onAction(
                                  const CommunityWriteAction.setLocation(null),
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            // 4. 제목 입력
                            _buildSectionLabel('제목', isRequired: true),
                            const SizedBox(height: 8),
                            _buildInputField(
                              hintText: '제목을 입력해주세요',
                              initialValue: state.title,
                              maxLength: 50,
                              onChanged: (val) => onAction(
                                CommunityWriteAction.changeTitle(val),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 5. 내용 입력
                            _buildSectionLabel('내용', isRequired: true),
                            const SizedBox(height: 8),
                            _buildInputField(
                              hintText: '내용을 입력해주세요',
                              initialValue: state.content,
                              maxLines: 8,
                              height: 180,
                              maxLength: 10000,
                              onChanged: (val) => onAction(
                                CommunityWriteAction.changeContent(val),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                // 하단 업로드 버튼 바
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
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
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            offset: Offset(0, -4),
            blurRadius: 4,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: state.isUploadEnabled
              ? () => onAction(const CommunityWriteAction.tapUpload())
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
          child: state.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.white,
                  ),
                )
              : const Text(
                  '업로드',
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

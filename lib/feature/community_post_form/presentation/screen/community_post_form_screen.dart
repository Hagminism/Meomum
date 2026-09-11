import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community_post_form/presentation/component/community_post_form_media_preview_list.dart';
import 'package:meomum/feature/community_post_form/presentation/model/community_post_form_media.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_action.dart';
import 'package:meomum/feature/community_write/presentation/component/category/community_category_selector_button.dart';
import 'package:meomum/feature/community_write/presentation/component/media_picker_button.dart';
import 'package:meomum/feature/community_write/presentation/component/selected_location_field.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostFormScreen extends StatelessWidget {
  final String appBarTitle;
  final String uploadButtonLabel;
  final CommunityRegion selectedRegion;
  final CommunityCategory category;
  final List<CommunityPostFormMedia> mediaItems;
  final CommunityPlace? selectedPlace;
  final String title;
  final String content;
  final bool isUploadEnabled;
  final bool isLoading;
  final void Function(CommunityPostFormAction) onAction;

  const CommunityPostFormScreen({
    super.key,
    required this.appBarTitle,
    required this.uploadButtonLabel,
    required this.selectedRegion,
    required this.category,
    required this.mediaItems,
    required this.selectedPlace,
    required this.title,
    required this.content,
    required this.isUploadEnabled,
    required this.isLoading,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (!didPop) {
            onAction(const CommunityPostFormAction.tapBack());
          }
        },
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
                          title: appBarTitle,
                          titleColor: const Color(0xFF646465),
                          showCloseButton: true,
                          onClosePressed: isLoading
                              ? null
                              : () => onAction(
                                  const CommunityPostFormAction.tapBack(),
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
                            _buildSectionLabel('게시할 지역', isRequired: true),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: isLoading
                                  ? null
                                  : () => onAction(
                                      const CommunityPostFormAction.tapRegionSelect(),
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
                                        '${selectedRegion.upperRegion} ${selectedRegion.lowerRegion}',
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
                            _buildSectionLabel('게시판', isRequired: true),
                            const SizedBox(height: 8),
                            CommunityCategorySelectorButton(
                              selectedCategory: category,
                              onTap: isLoading
                                  ? () {}
                                  : () => onAction(
                                      const CommunityPostFormAction.tapCategorySelect(),
                                    ),
                            ),
                            const SizedBox(height: 20),
                            _buildSectionLabel('사진이나 동영상'),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  MediaPickerButton(
                                    onTap: isLoading
                                        ? () {}
                                        : () => onAction(
                                            const CommunityPostFormAction.pickMedia(),
                                          ),
                                  ),
                                  if (mediaItems.isNotEmpty) ...[
                                    const SizedBox(width: 10),
                                    CommunityPostFormMediaPreviewList(
                                      mediaItems: mediaItems,
                                      onRemove: isLoading
                                          ? (int _) {}
                                          : (int index) => onAction(
                                              CommunityPostFormAction.removeMedia(
                                                index,
                                              ),
                                            ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildSectionLabel('위치'),
                            const SizedBox(height: 8),
                            SelectedLocationField(
                              place: selectedPlace,
                              onTap: isLoading
                                  ? () {}
                                  : () => onAction(
                                      const CommunityPostFormAction.tapLocationSearch(),
                                    ),
                              onClear: isLoading
                                  ? () {}
                                  : () => onAction(
                                      const CommunityPostFormAction.setLocation(
                                        null,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 20),
                            _buildSectionLabel('제목', isRequired: true),
                            const SizedBox(height: 8),
                            _buildInputField(
                              hintText: '제목을 입력해주세요',
                              initialValue: title,
                              maxLength: 50,
                              onChanged: (String value) => onAction(
                                CommunityPostFormAction.changeTitle(value),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildSectionLabel('내용', isRequired: true),
                            const SizedBox(height: 8),
                            _buildInputField(
                              hintText: '내용을 입력해주세요',
                              initialValue: content,
                              maxLines: 8,
                              height: 180,
                              maxLength: 10000,
                              onChanged: (String value) => onAction(
                                CommunityPostFormAction.changeContent(value),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
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
        enabled: !isLoading,
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
          onPressed: isUploadEnabled
              ? () => onAction(const CommunityPostFormAction.tapUpload())
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
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.white,
                  ),
                )
              : Text(
                  uploadButtonLabel,
                  style: const TextStyle(
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

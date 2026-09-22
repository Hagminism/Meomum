import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/presentation/component/dialog/two_button_dialog/two_button_dialog.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/community_regions.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community/presentation/component/region/community_region_bottom_sheet.dart';
import 'package:meomum/feature/community/presentation/screen/community_view_model.dart';
import 'package:meomum/feature/community_post_form/presentation/component/category/community_category_bottom_sheet.dart';
import 'package:meomum/feature/community_post_form/presentation/component/community_deadline_picker.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_action.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_event.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_screen.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_view_model.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostFormScreenRoot extends ConsumerStatefulWidget {
  final String? postId;

  const CommunityPostFormScreenRoot({
    super.key,
    this.postId,
  });

  @override
  ConsumerState<CommunityPostFormScreenRoot> createState() =>
      _CommunityPostFormScreenRootState();
}

class _CommunityPostFormScreenRootState
    extends ConsumerState<CommunityPostFormScreenRoot> {
  StreamSubscription<CommunityPostFormEvent>? _subscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = ref.read(
        communityPostFormViewModelProvider(widget.postId).notifier,
      );
      _subscription = viewModel.eventStream.listen(_handleEvent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      communityPostFormViewModelProvider(widget.postId),
    );
    final viewModel = ref.read(
      communityPostFormViewModelProvider(widget.postId).notifier,
    );

    return CommunityPostFormScreen(
      appBarTitle: widget.postId == null ? '새 글 작성' : '글 수정',
      uploadButtonLabel: widget.postId == null ? '업로드' : '수정하기',
      state: state,
      onAction: (CommunityPostFormAction action) async {
        switch (action) {
          case TapRegionSelect():
            await _showRegionSelector(state.selectedRegion, viewModel);
          case TapCategorySelect():
            await _showCategorySelector(state.category, viewModel);
          case TapLocationSearch():
            final selectedPlace = await context.push<CommunityPlace>(
              '${GoRouterState.of(context).uri.path}/${Routes.communityLocationSearch}',
            );
            if (selectedPlace != null && mounted) {
              viewModel.onAction(
                CommunityPostFormAction.setLocation(selectedPlace),
              );
            }
          case TapRecruitmentDeadline():
            final selectedDate = await showCommunityDeadlinePicker(
              context: context,
              initialDate: state.recruitmentDeadline ?? DateTime.now(),
            );
            if (selectedDate != null && mounted) {
              viewModel.onAction(
                CommunityPostFormAction.selectRecruitmentDeadline(selectedDate),
              );
            }
          case TapBack():
            await _handleBack(state.hasChanges, state.isLoading);
          case SelectRegion():
          case SelectCategory():
          case PickMedia():
          case RemoveMedia():
          case SetLocation():
          case ChangeTitle():
          case ChangeContent():
          case ChangeWageType():
          case ChangeWageAmount():
          case ChangeWorkingTime():
          case SelectRecruitmentDeadline():
          case ToggleAlwaysRecruiting():
          case TapUpload():
            viewModel.onAction(action);
        }
      },
    );
  }

  void _handleEvent(CommunityPostFormEvent event) {
    if (!mounted) return;

    switch (event) {
      case PostCreated(:final post):
        ref.read(communityViewModelProvider.notifier).addPost(post);
        AppSnackBar.showSuccess(context, '게시글이 등록되었습니다.');
        context.pop();
      case PostUpdated():
        context.pop(true);
      case ShowMessage(:final message):
        AppSnackBar.showError(context, message);
    }
  }

  Future<void> _showCategorySelector(
    CommunityCategory selectedCategory,
    CommunityPostFormViewModel viewModel,
  ) async {
    final category = await showModalBottomSheet<CommunityCategory>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: AppColors.writeBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext bottomSheetContext) {
        return CommunityCategoryBottomSheet(
          categories: CommunityCategory.values,
          selectedCategory: selectedCategory,
          onClose: () => Navigator.of(bottomSheetContext).pop(),
          onSelected: (CommunityCategory selected) {
            Navigator.of(bottomSheetContext).pop(selected);
          },
        );
      },
    );

    if (!mounted || category == null) return;
    viewModel.onAction(CommunityPostFormAction.selectCategory(category));
  }

  Future<void> _showRegionSelector(
    CommunityRegion selectedRegion,
    CommunityPostFormViewModel viewModel,
  ) async {
    final region = await showModalBottomSheet<CommunityRegion>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return CommunityRegionBottomSheet(
          regions: CommunityRegions.all,
          selectedRegion: selectedRegion,
          showViewLabel: false,
          onClose: () => Navigator.of(bottomSheetContext).pop(),
          onConfirm: (CommunityRegion confirmedRegion) {
            Navigator.of(bottomSheetContext).pop(confirmedRegion);
          },
        );
      },
    );

    if (!mounted || region == null) return;
    viewModel.onAction(CommunityPostFormAction.selectRegion(region));
  }

  Future<void> _handleBack(bool hasChanges, bool isLoading) async {
    if (isLoading) return;

    if (!hasChanges ||
        await TwoButtonDialog.show(
          context,
          title: '작성 중인 내용이 있습니다.',
          message: '저장하지 않고 나가시겠습니까?',
          cancelLabel: '취소',
          confirmLabel: '나가기',
        )) {
      if (mounted) context.pop();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

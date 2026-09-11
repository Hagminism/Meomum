import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/community_regions.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community/presentation/component/region/community_region_bottom_sheet.dart';
import 'package:meomum/core/presentation/component/dialog/two_button_dialog/two_button_dialog.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_action.dart';
import 'package:meomum/feature/community_write/presentation/component/category/community_category_bottom_sheet.dart';
import 'package:meomum/feature/community_edit_post/presentation/screen/community_edit_post_event.dart';
import 'package:meomum/feature/community_edit_post/presentation/screen/community_edit_post_screen.dart';
import 'package:meomum/feature/community_edit_post/presentation/screen/community_edit_post_view_model.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityEditPostScreenRoot extends ConsumerStatefulWidget {
  final String postId;

  const CommunityEditPostScreenRoot({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<CommunityEditPostScreenRoot> createState() =>
      _CommunityEditPostScreenRootState();
}

class _CommunityEditPostScreenRootState
    extends ConsumerState<CommunityEditPostScreenRoot> {
  StreamSubscription<CommunityEditPostEvent>? _subscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = ref.read(
        communityEditPostViewModelProvider(widget.postId).notifier,
      );
      _subscription = viewModel.eventStream.listen((event) {
        if (!mounted) return;

        switch (event) {
          case PostUpdatedSuccess():
            context.pop(true);
          case ShowMessage(:final message):
            AppSnackBar.showError(context, message);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      communityEditPostViewModelProvider(widget.postId),
    );
    final viewModel = ref.read(
      communityEditPostViewModelProvider(widget.postId).notifier,
    );

    return CommunityEditPostScreen(
      state: state,
      onAction: (CommunityPostFormAction action) async {
        switch (action) {
          case TapRegionSelect():
            _showRegionSelector(state.selectedRegion);
            break;
          case TapCategorySelect():
            _showCategorySelector(state.category);
            break;
          case TapLocationSearch():
            final selectedPlace = await context.push<CommunityPlace>(
              '${GoRouterState.of(context).uri.path}/${Routes.communityLocationSearch}',
            );
            if (selectedPlace != null && mounted) {
              viewModel.onAction(
                CommunityPostFormAction.setLocation(selectedPlace),
              );
            }
            break;
          case TapBack():
            await _handleBack(state.hasChanges, state.isLoading);
            break;
          case SelectRegion():
          case SelectCategory():
          case PickMedia():
          case RemoveMedia():
          case SetLocation():
          case ChangeTitle():
          case ChangeContent():
          case TapUpload():
            viewModel.onAction(action);
            break;
        }
      },
    );
  }

  Future<void> _showCategorySelector(
    CommunityCategory selectedCategory,
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

    ref
        .read(communityEditPostViewModelProvider(widget.postId).notifier)
        .onAction(CommunityPostFormAction.selectCategory(category));
  }

  Future<void> _showRegionSelector(CommunityRegion selectedRegion) async {
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

    ref
        .read(communityEditPostViewModelProvider(widget.postId).notifier)
        .onAction(CommunityPostFormAction.selectRegion(region));
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

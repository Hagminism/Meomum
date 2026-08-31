import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/community_regions.dart';
import 'package:meomum/feature/community/presentation/component/region/community_region_bottom_sheet.dart';
import 'package:meomum/feature/community/presentation/screen/community_view_model.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_action.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_event.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_screen.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_view_model.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityWriteScreenRoot extends ConsumerStatefulWidget {
  const CommunityWriteScreenRoot({super.key});

  @override
  ConsumerState<CommunityWriteScreenRoot> createState() =>
      _CommunityWriteScreenRootState();
}

class _CommunityWriteScreenRootState
    extends ConsumerState<CommunityWriteScreenRoot> {
  StreamSubscription<CommunityWriteEvent>? _subscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(communityWriteViewModelProvider.notifier);

      _subscription = viewModel.eventStream.listen((event) async {
        if (!mounted) return;

        switch (event) {
          case PostCreatedSuccess(:final post):
            ref.read(communityViewModelProvider.notifier).addPost(post);

            AppSnackBar.showSuccess(context, '게시글이 등록되었습니다.');

            context.pop();
            break;
          case ShowMessage(:final message):
            AppSnackBar.showError(context, message);
            break;
          case Pop():
            context.pop();
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityWriteViewModelProvider);
    final viewModel = ref.read(communityWriteViewModelProvider.notifier);

    return CommunityWriteScreen(
      state: state,
      onAction: (action) async {
        switch (action) {
          case TapRegionSelect():
            _showRegionSelector(state.selectedRegion);
            break;
          case TapLocationSearch():
            final selectedPlace = await context.push<CommunityPlace>(
              '${Routes.community}/${Routes.communityWrite}/${Routes.communityLocationSearch}',
            );
            if (selectedPlace != null && mounted) {
              ref
                  .read(communityWriteViewModelProvider.notifier)
                  .onAction(CommunityWriteAction.setLocation(selectedPlace));
            }
            break;
          case SelectRegion():
          case SelectCategory():
          case PickMedia():
          case RemoveMedia():
          case SetLocation():
          case ChangeTitle():
          case ChangeContent():
          case TapUpload():
          case TapBack():
            viewModel.onAction(action);
            break;
        }
      },
    );
  }

  /// 지역 선택 바텀 시트를 열고 선택 결과를 작성 상태에 반영합니다.
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
          onClose: () {
            Navigator.of(bottomSheetContext).pop();
          },
          onConfirm: (CommunityRegion confirmedRegion) {
            Navigator.of(bottomSheetContext).pop(confirmedRegion);
          },
        );
      },
    );

    if (!mounted || region == null) {
      return;
    }

    ref
        .read(communityWriteViewModelProvider.notifier)
        .onAction(CommunityWriteAction.selectRegion(region));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/presentation/service/share_post_handler.dart';
import 'package:meomum/core/presentation/service/community_image_cleanup_lifecycle.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/community_regions.dart';
import 'package:meomum/feature/community/presentation/component/region/community_region_bottom_sheet.dart';
import 'package:meomum/feature/community/presentation/screen/community_action.dart';
import 'package:meomum/feature/community/presentation/screen/community_event.dart';
import 'package:meomum/feature/community/presentation/screen/community_screen.dart';
import 'package:meomum/feature/community/presentation/screen/community_view_model.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityScreenRoot extends ConsumerStatefulWidget {
  final CommunityCategory initialCategory;

  const CommunityScreenRoot({
    super.key,
    this.initialCategory = CommunityCategory.free,
  });

  @override
  ConsumerState<CommunityScreenRoot> createState() =>
      _CommunityScreenRootState();
}

class _CommunityScreenRootState extends ConsumerState<CommunityScreenRoot> {
  StreamSubscription<CommunityEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      unawaited(
        ref.read(communityImageCleanupLifecycleProvider).runNow(force: true),
      );

      final viewModel = ref.read(communityViewModelProvider.notifier);

      viewModel.onAction(
        CommunityAction.selectCategory(widget.initialCategory),
      );

      _eventSubscription = viewModel.eventStream.listen(
        (CommunityEvent event) {
          if (!mounted) {
            return;
          }

          switch (event) {
            case ShowMessage(:final message):
              AppSnackBar.showError(context, message);
          }
        },
      );
    });
  }

  @override
  void didUpdateWidget(covariant CommunityScreenRoot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialCategory == widget.initialCategory) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref
          .read(communityViewModelProvider.notifier)
          .onAction(CommunityAction.selectCategory(widget.initialCategory));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityViewModelProvider);
    final viewModel = ref.read(communityViewModelProvider.notifier);

    return CommunityScreen(
      state: state,
      onShare: (CommunityPost post, BuildContext shareContext) {
        ref
            .read(sharePostHandlerProvider)
            .sharePost(
              post: post,
              shareContext: shareContext,
            );
      },
      onAction: (CommunityAction action) {
        switch (action) {
          case TapRegionFilter():
            _showRegionSelector(state.selectedRegion);
            break;
          case SelectRegion():
          case SelectCategory():
          case ChangeImagePage():
          case ToggleLike():
          case TapComment():
            viewModel.onAction(action);
            break;
          case TapPost(:final postId):
            context.push('${Routes.community}/post-detail/$postId');
            break;
          case LoadMore():
          case Refresh():
            viewModel.onAction(action);
            break;
          case TapWrite():
            context.push('${Routes.community}/${Routes.communityWrite}');
            break;
        }
      },
    );
  }

  /// 지역 선택 바텀 시트를 열고 선택 결과를 ViewModel에 전달합니다.
  Future<void> _showRegionSelector(
    CommunityRegion selectedRegion,
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
        .read(communityViewModelProvider.notifier)
        .onAction(CommunityAction.selectRegion(region));
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}

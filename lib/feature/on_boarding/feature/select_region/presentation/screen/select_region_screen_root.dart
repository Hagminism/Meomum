import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/community_regions.dart';
import 'package:meomum/feature/community/presentation/component/region/community_region_bottom_sheet.dart';
import 'package:meomum/feature/on_boarding/feature/select_region/presentation/screen/select_region_action.dart';
import 'package:meomum/feature/on_boarding/feature/select_region/presentation/screen/select_region_event.dart';
import 'package:meomum/feature/on_boarding/feature/select_region/presentation/screen/select_region_screen.dart';
import 'package:meomum/feature/on_boarding/feature/select_region/presentation/screen/select_region_view_model.dart';
import 'package:meomum/ui/app_colors.dart';

class SelectRegionScreenRoot extends ConsumerStatefulWidget {
  const SelectRegionScreenRoot({super.key});

  @override
  ConsumerState<SelectRegionScreenRoot> createState() =>
      _SelectRegionScreenRootState();
}

class _SelectRegionScreenRootState
    extends ConsumerState<SelectRegionScreenRoot> {
  StreamSubscription<SelectRegionEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = ref.read(selectRegionViewModelProvider.notifier);
      _eventSubscription = viewModel.eventStream.listen(
        (SelectRegionEvent event) {
          if (!mounted) return;

          switch (event) {
            case ShowError(:final message):
              AppSnackBar.showError(context, message);
            case RegionSaved():
              context.go(Routes.home);
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(selectRegionViewModelProvider);
    final viewModel = ref.read(selectRegionViewModelProvider.notifier);

    return SelectRegionScreen(
      state: state,
      onAction: (SelectRegionAction action) {
        switch (action) {
          case TapRegionField():
            _showRegionSelector();
          case SelectRegion():
          case TapSubmit():
            viewModel.onAction(action);
          case TapBack():
            context.pop();
        }
      },
    );
  }

  Future<void> _showRegionSelector() async {
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
          selectedRegion: CommunityRegions.pohang,
          title: '거주 지역 선택',
          confirmButtonLabel: '이 지역을 선택할게요',
          showViewLabel: false,
          onClose: () {
            Navigator.of(bottomSheetContext).pop();
          },
          onConfirm: (CommunityRegion selectedRegion) {
            Navigator.of(bottomSheetContext).pop(selectedRegion);
          },
        );
      },
    );

    if (!mounted || region == null) return;

    ref
        .read(selectRegionViewModelProvider.notifier)
        .onAction(SelectRegionAction.selectRegion(region));
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}

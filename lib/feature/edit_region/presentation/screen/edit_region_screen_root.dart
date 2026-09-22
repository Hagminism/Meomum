import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/community_regions.dart';
import 'package:meomum/feature/community/presentation/component/region/community_region_bottom_sheet.dart';
import 'package:meomum/feature/edit_region/presentation/screen/edit_region_action.dart';
import 'package:meomum/feature/edit_region/presentation/screen/edit_region_event.dart';
import 'package:meomum/feature/edit_region/presentation/screen/edit_region_screen.dart';
import 'package:meomum/feature/edit_region/presentation/screen/edit_region_view_model.dart';
import 'package:meomum/ui/app_colors.dart';

class EditRegionScreenRoot extends ConsumerStatefulWidget {
  const EditRegionScreenRoot({super.key});

  @override
  ConsumerState<EditRegionScreenRoot> createState() =>
      _EditRegionScreenRootState();
}

class _EditRegionScreenRootState extends ConsumerState<EditRegionScreenRoot> {
  StreamSubscription<EditRegionEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = ref.read(editRegionViewModelProvider.notifier);
      _eventSubscription = viewModel.eventStream.listen(
        (EditRegionEvent event) {
          if (!mounted) return;

          switch (event) {
            case ShowError(:final message):
              AppSnackBar.showError(context, message);
            case RegionSaved():
              context.pop(true);
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editRegionViewModelProvider);
    final viewModel = ref.read(editRegionViewModelProvider.notifier);

    return EditRegionScreen(
      state: state,
      onAction: (EditRegionAction action) {
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
    final selectedRegion =
        ref.read(editRegionViewModelProvider).selectedRegion ??
        CommunityRegions.pohang;
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
        .read(editRegionViewModelProvider.notifier)
        .onAction(EditRegionAction.selectRegion(region));
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}

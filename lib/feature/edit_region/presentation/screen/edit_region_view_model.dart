import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/community_regions.dart';
import 'package:meomum/feature/edit_region/presentation/screen/edit_region_action.dart';
import 'package:meomum/feature/edit_region/presentation/screen/edit_region_event.dart';
import 'package:meomum/feature/edit_region/presentation/screen/edit_region_state.dart';

class EditRegionViewModel extends Notifier<EditRegionState> {
  @override
  EditRegionState build() {
    ref.onDispose(() => _eventController.close());

    final currentUser = ref.read(authRepositoryProvider).currentUser;
    return EditRegionState(
      selectedRegion: _findRegion(
        upperRegion: currentUser?.upperRegion,
        lowerRegion: currentUser?.lowerRegion,
      ),
    );
  }

  final StreamController<EditRegionEvent> _eventController =
      StreamController<EditRegionEvent>.broadcast();

  Stream<EditRegionEvent> get eventStream => _eventController.stream;

  void onAction(EditRegionAction action) {
    switch (action) {
      case TapRegionField():
      case TapBack():
        break;
      case SelectRegion(:final region):
        state = state.copyWith(selectedRegion: region);
      case TapSubmit():
        _submit();
    }
  }

  Future<void> _submit() async {
    final selectedRegion = state.selectedRegion;
    if (selectedRegion == null || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);

    final result = await ref
        .read(authRepositoryProvider)
        .updateRegion(
          upperRegion: selectedRegion.upperRegion,
          lowerRegion: selectedRegion.lowerRegion,
        );

    if (!ref.mounted) {
      return;
    }

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
        _eventController.add(const EditRegionEvent.regionSaved());
      case Failure(message: final message):
        state = state.copyWith(isLoading: false);
        _eventController.add(EditRegionEvent.showError(message));
    }
  }

  CommunityRegion? _findRegion({
    required String? upperRegion,
    required String? lowerRegion,
  }) {
    if (upperRegion == null || lowerRegion == null) {
      return null;
    }

    for (final region in CommunityRegions.all) {
      if (region.upperRegion == upperRegion &&
          region.lowerRegion == lowerRegion) {
        return region;
      }
    }

    return null;
  }
}

final editRegionViewModelProvider =
    NotifierProvider.autoDispose<EditRegionViewModel, EditRegionState>(
      EditRegionViewModel.new,
    );

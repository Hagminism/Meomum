import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/on_boarding/feature/select_region/presentation/screen/select_region_action.dart';
import 'package:meomum/feature/on_boarding/feature/select_region/presentation/screen/select_region_event.dart';
import 'package:meomum/feature/on_boarding/feature/select_region/presentation/screen/select_region_state.dart';

class SelectRegionViewModel extends Notifier<SelectRegionState> {
  @override
  SelectRegionState build() {
    ref.onDispose(() => _eventController.close());

    return const SelectRegionState();
  }

  final StreamController<SelectRegionEvent> _eventController =
      StreamController<SelectRegionEvent>.broadcast();

  Stream<SelectRegionEvent> get eventStream => _eventController.stream;

  void onAction(SelectRegionAction action) {
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
        _eventController.add(const SelectRegionEvent.regionSaved());
      case Failure(message: final message):
        state = state.copyWith(isLoading: false);
        _eventController.add(SelectRegionEvent.showError(message));
    }
  }
}

final selectRegionViewModelProvider =
    NotifierProvider<SelectRegionViewModel, SelectRegionState>(
      SelectRegionViewModel.new,
    );

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:meomum/feature/store_detail/presentation/screen/store_detail_state.dart';

class StoreDetailViewModel extends Notifier<StoreDetailState> {
  @override
  StoreDetailState build() {
    return const StoreDetailState();
  }

  void onAction(StoreDetailAction action) {
    switch (action) {
      case TapBack():
      case TapNaverMap():
        break;
      case TapRetry():
        resetWebViewState();
    }
  }

  void onProgress(int progress) {
    if (!ref.mounted) return;
    state = state.copyWith(
      isWebViewLoading: progress < 100,
      webViewProgress: progress,
    );
  }

  void onPageStarted() {
    if (!ref.mounted) return;
    state = state.copyWith(
      hasWebViewError: false,
      isWebViewLoading: true,
      webViewProgress: 0,
    );
  }

  void onPageFinished() {
    if (!ref.mounted) return;
    state = state.copyWith(
      hasWebViewError: false,
      isWebViewLoading: false,
      webViewProgress: 100,
    );
  }

  void onMainFrameError() {
    if (!ref.mounted) return;
    state = state.copyWith(
      hasWebViewError: true,
      isWebViewLoading: false,
    );
  }

  void resetWebViewState() {
    if (!ref.mounted) return;
    state = state.copyWith(
      isWebViewLoading: true,
      hasWebViewError: false,
      webViewProgress: 0,
    );
  }
}

final storeDetailViewModelProvider =
    NotifierProvider.autoDispose<StoreDetailViewModel, StoreDetailState>(
      StoreDetailViewModel.new,
    );

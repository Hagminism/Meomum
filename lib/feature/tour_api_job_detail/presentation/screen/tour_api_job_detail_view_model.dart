import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/community/tour_api_job_posting_repository_impl.dart';
import 'package:meomum/core/domain/repository/community/tour_api_job_posting_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/tour_api_job_detail/presentation/screen/tour_api_job_detail_action.dart';
import 'package:meomum/feature/tour_api_job_detail/presentation/screen/tour_api_job_detail_state.dart';

class TourApiJobDetailViewModel extends Notifier<TourApiJobDetailState> {
  final String empmnInfoNo;

  TourApiJobDetailViewModel(this.empmnInfoNo);

  late final TourApiJobPostingRepository _repository;

  @override
  TourApiJobDetailState build() {
    _repository = ref.watch(tourApiJobPostingRepositoryProvider);
    Future.microtask(_loadPosting);
    return const TourApiJobDetailState();
  }

  void onAction(TourApiJobDetailAction action) {
    switch (action) {
      case TapBack():
      case TapOriginalLink():
        break;
      case TapRetryDetail():
        _loadDetail();
    }
  }

  Future<void> _loadPosting() async {
    if (!ref.mounted) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    final result = await _repository.getJobPostingById(
      empmnInfoNo: empmnInfoNo,
    );
    if (!ref.mounted) return;

    switch (result) {
      case Success(data: final posting):
        state = state.copyWith(
          posting: posting,
          detail: null,
          isLoading: false,
          errorMessage: null,
          isDetailLoading: false,
          detailErrorMessage: null,
        );
        await _loadDetail();
      case Failure(message: final message):
        state = state.copyWith(
          isLoading: false,
          errorMessage: message,
        );
    }
  }

  Future<void> _loadDetail() async {
    if (state.posting == null || state.isDetailLoading) return;

    state = state.copyWith(
      isDetailLoading: true,
      detailErrorMessage: null,
    );

    final result = await _repository.getDetail(
      empmnInfoNo: empmnInfoNo,
    );
    if (!ref.mounted) return;

    switch (result) {
      case Success(data: final detail):
        state = state.copyWith(
          detail: detail,
          isDetailLoading: false,
          detailErrorMessage: null,
        );
      case Failure(message: final message):
        state = state.copyWith(
          isDetailLoading: false,
          detailErrorMessage: message,
        );
    }
  }
}

final tourApiJobDetailViewModelProvider = NotifierProvider.autoDispose
    .family<TourApiJobDetailViewModel, TourApiJobDetailState, String>(
      TourApiJobDetailViewModel.new,
    );

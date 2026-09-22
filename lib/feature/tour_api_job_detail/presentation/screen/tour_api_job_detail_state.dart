import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/tour_api_job_posting.dart';

part 'tour_api_job_detail_state.freezed.dart';

@freezed
sealed class TourApiJobDetailState with _$TourApiJobDetailState {
  const factory TourApiJobDetailState({
    TourApiJobPosting? posting,
    Map<String, dynamic>? detail,
    @Default(true) bool isLoading,
    String? errorMessage,
    @Default(false) bool isDetailLoading,
    String? detailErrorMessage,
  }) = _TourApiJobDetailState;
}

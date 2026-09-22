import 'package:freezed_annotation/freezed_annotation.dart';

part 'tour_api_job_detail_action.freezed.dart';

@freezed
sealed class TourApiJobDetailAction with _$TourApiJobDetailAction {
  const factory TourApiJobDetailAction.tapBack() = TapBack;
  const factory TourApiJobDetailAction.tapRetryDetail() = TapRetryDetail;
  const factory TourApiJobDetailAction.tapOriginalLink() = TapOriginalLink;
}

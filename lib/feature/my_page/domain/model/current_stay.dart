import 'package:freezed_annotation/freezed_annotation.dart';

part 'current_stay.freezed.dart';

@freezed
abstract class CurrentStay with _$CurrentStay {
  const factory CurrentStay({
    required String location,
    required String dateRange,
    required String jobType,
    required String accommodation,
    String? thumbnailUrl,
  }) = _CurrentStay;
}

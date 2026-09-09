import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_event.freezed.dart';

@freezed
sealed class ReportEvent with _$ReportEvent {
  const factory ReportEvent.submitted() = Submitted;
  const factory ReportEvent.showMessage(String message) = ShowMessage;
}

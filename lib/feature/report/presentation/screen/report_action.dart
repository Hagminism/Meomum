import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_action.freezed.dart';

@freezed
sealed class ReportAction with _$ReportAction {
  const factory ReportAction.tapBack() = TapBack;
  const factory ReportAction.retryPost() = RetryPost;
  const factory ReportAction.changeTitle(String title) = ChangeTitle;
  const factory ReportAction.changeContent(String content) = ChangeContent;
  const factory ReportAction.pickPhotos() = PickPhotos;
  const factory ReportAction.removePhoto(int index) = RemovePhoto;
  const factory ReportAction.submit() = Submit;
}

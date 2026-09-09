import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';

part 'report_state.freezed.dart';

@freezed
abstract class ReportState with _$ReportState {
  const ReportState._();

  const factory ReportState({
    CommunityPost? post,
    @Default(false) bool isFetching,
    String? loadError,
    @Default('') String title,
    @Default('') String content,
    @Default([]) List<XFile> mediaFiles,
    @Default(false) bool isSubmitting,
  }) = _ReportState;

  bool get isFormVisible => post != null && !isFetching && loadError == null;

  bool get isSubmitEnabled =>
      isFormVisible &&
      title.trim().isNotEmpty &&
      title.trim().length <= 50 &&
      content.trim().isNotEmpty &&
      content.trim().length <= 10000 &&
      !isSubmitting;
}

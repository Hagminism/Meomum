import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';

part 'community_write_state.freezed.dart';

@freezed
abstract class CommunityWriteState with _$CommunityWriteState {
  const CommunityWriteState._();

  const factory CommunityWriteState({
    required CommunityRegion selectedRegion,
    CommunityRegion? initialRegion,
    @Default(CommunityCategory.free) CommunityCategory category,
    @Default([]) List<XFile> mediaFiles,
    CommunityPlace? selectedPlace,
    @Default('') String title,
    @Default('') String content,
    String? wageType,
    @Default('') String wageAmount,
    @Default('') String workingTime,
    DateTime? recruitmentDeadline,
    @Default(false) bool isAlwaysRecruiting,
    @Default(false) bool isLoading,
  }) = _CommunityWriteState;

  bool get isUploadEnabled =>
      title.trim().isNotEmpty &&
      title.trim().length <= 50 &&
      content.trim().isNotEmpty &&
      content.trim().length <= 10000 &&
      (!isJob || isJobFieldsValid) &&
      !isLoading;

  bool get isJob => category == CommunityCategory.job;

  bool get isJobFieldsValid {
    if (!isAlwaysRecruiting && recruitmentDeadline == null) return false;
    if (wageAmount.trim().isNotEmpty && wageType == null) return false;
    if (wageType == '협의' && wageAmount.trim().isNotEmpty) return false;
    if (wageType != null && wageType != '협의' && wageAmount.trim().isEmpty) {
      return false;
    }
    return wageAmount.trim().isEmpty || double.tryParse(wageAmount) != null;
  }

  String get uploadValidationMessage {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      return '제목과 내용을 모두 입력해주세요.';
    }
    if (isJob && !isAlwaysRecruiting && recruitmentDeadline == null) {
      return '모집 마감일 또는 상시 모집을 선택해주세요.';
    }
    if (isJob && wageAmount.trim().isNotEmpty && wageType == null) {
      return '급여 형태를 먼저 선택해주세요.';
    }
    if (isJob && wageType == '협의' && wageAmount.trim().isNotEmpty) {
      return '급여 협의는 금액을 입력하지 않습니다.';
    }
    if (isJob &&
        wageType != null &&
        wageType != '협의' &&
        wageAmount.trim().isEmpty) {
      return '급여 금액을 입력해주세요.';
    }
    return '입력 내용을 확인해주세요.';
  }

  bool get hasChanges =>
      selectedRegion != (initialRegion ?? selectedRegion) ||
      category != CommunityCategory.free ||
      mediaFiles.isNotEmpty ||
      selectedPlace != null ||
      title.trim().isNotEmpty ||
      content.trim().isNotEmpty ||
      wageType != null ||
      wageAmount.trim().isNotEmpty ||
      workingTime.trim().isNotEmpty ||
      recruitmentDeadline != null ||
      isAlwaysRecruiting;
}

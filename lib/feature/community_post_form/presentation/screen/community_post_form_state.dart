import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community_post_form/presentation/model/community_post_form_media.dart';

part 'community_post_form_state.freezed.dart';

@freezed
abstract class CommunityPostFormState with _$CommunityPostFormState {
  const CommunityPostFormState._();

  const factory CommunityPostFormState({
    String? postId,
    required CommunityRegion selectedRegion,
    CommunityRegion? initialRegion,
    CommunityPost? originalPost,
    @Default(CommunityCategory.free) CommunityCategory category,
    @Default([]) List<CommunityPostFormMedia> mediaItems,
    CommunityPlace? selectedPlace,
    @Default('') String title,
    @Default('') String content,
    String? wageType,
    @Default('') String wageAmount,
    @Default('') String workingTime,
    DateTime? recruitmentDeadline,
    @Default(false) bool isAlwaysRecruiting,
    @Default(false) bool isInitializing,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _CommunityPostFormState;

  bool get isEditing => postId != null;

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

  bool get hasChanges {
    if (isEditing) {
      final post = originalPost;
      if (post == null) return false;

      final currentImagePaths = mediaItems
          .where((CommunityPostFormMedia media) => !media.isLocal)
          .map(
            (CommunityPostFormMedia media) => media.existingImage!.storagePath,
          )
          .toList(growable: false);
      final originalImagePaths = post.images
          .map((image) => image.storagePath)
          .toList(growable: false);

      return selectedRegion != post.region ||
          category != post.category ||
          selectedPlace != post.place ||
          title.trim() != post.title.trim() ||
          content.trim() != post.content.trim() ||
          wageType != post.jobWageType ||
          double.tryParse(wageAmount) != post.jobWageAmount ||
          workingTime.trim() != (post.jobWorkingTime ?? '').trim() ||
          recruitmentDeadline != post.jobRecruitmentDeadline ||
          isAlwaysRecruiting != post.jobIsAlwaysRecruiting ||
          !listEquals(currentImagePaths, originalImagePaths) ||
          mediaItems.any((CommunityPostFormMedia media) => media.isLocal);
    }

    return selectedRegion != (initialRegion ?? selectedRegion) ||
        category != CommunityCategory.free ||
        mediaItems.isNotEmpty ||
        selectedPlace != null ||
        title.trim().isNotEmpty ||
        content.trim().isNotEmpty ||
        wageType != null ||
        wageAmount.trim().isNotEmpty ||
        workingTime.trim().isNotEmpty ||
        recruitmentDeadline != null ||
        isAlwaysRecruiting;
  }

  bool get isUploadEnabled =>
      !isInitializing &&
      errorMessage == null &&
      title.trim().isNotEmpty &&
      title.trim().length <= 50 &&
      content.trim().isNotEmpty &&
      content.trim().length <= 10000 &&
      (!isJob || isJobFieldsValid) &&
      (!isEditing || hasChanges) &&
      !isLoading;

  String get uploadValidationMessage {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      return '제목과 내용을 모두 입력해주세요.';
    }
    if (isEditing && !hasChanges) {
      return '변경된 내용이 없습니다.';
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
}

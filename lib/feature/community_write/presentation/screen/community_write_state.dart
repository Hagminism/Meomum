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
    @Default(false) bool isLoading,
  }) = _CommunityWriteState;

  bool get isUploadEnabled =>
      title.trim().isNotEmpty &&
      title.trim().length <= 50 &&
      content.trim().isNotEmpty &&
      content.trim().length <= 10000 &&
      !isLoading;

  bool get hasChanges =>
      selectedRegion != (initialRegion ?? selectedRegion) ||
      category != CommunityCategory.free ||
      mediaFiles.isNotEmpty ||
      selectedPlace != null ||
      title.trim().isNotEmpty ||
      content.trim().isNotEmpty;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post_image.freezed.dart';
part 'community_post_image.g.dart';

@freezed
abstract class CommunityPostImage with _$CommunityPostImage {
  const factory CommunityPostImage({
    required String storagePath,
    required String publicUrl,
    required int sortOrder,
  }) = _CommunityPostImage;

  factory CommunityPostImage.fromJson(Map<String, Object?> json) =>
      _$CommunityPostImageFromJson(json);
}

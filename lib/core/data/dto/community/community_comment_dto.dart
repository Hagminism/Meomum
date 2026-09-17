import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_comment_dto.freezed.dart';
part 'community_comment_dto.g.dart';

@freezed
abstract class CommunityCommentDto with _$CommunityCommentDto {
  const factory CommunityCommentDto({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'author_id') required String authorId,
    required String content,
    @JsonKey(name: 'storage_path') String? storagePath,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    Map<String, dynamic>? profiles,
    Map<String, dynamic>? posts,
    @JsonKey(name: 'comment_likes') @Default([]) List<dynamic> commentLikes,
  }) = _CommunityCommentDto;

  factory CommunityCommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommunityCommentDtoFromJson(json);
}

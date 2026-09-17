import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/utils/extension/time_ago_extension.dart';

part 'community_comment.freezed.dart';
part 'community_comment.g.dart';

@freezed
abstract class CommunityComment with _$CommunityComment {
  const CommunityComment._();

  const factory CommunityComment({
    required String id,
    required String postId,
    String? parentId,
    required String authorId,
    required String nickname,
    @Default('동네이웃') String neighborhood,
    String? profileImageUrl,
    required String content,
    String? storagePath,
    String? imageUrl,
    required DateTime createdAt,
    @Default(0) int likeCount,
    @Default(false) bool isLiked,
    @Default(false) bool isDeleted,
    @Default(0) int replyCount,
    @Default('') String postTitle,
    @Default('') String postCategory,
  }) = _CommunityComment;

  String get timeLabel => createdAt.toTimeAgo();

  bool get isReply => parentId != null;

  factory CommunityComment.fromJson(Map<String, dynamic> json) =>
      _$CommunityCommentFromJson(json);
}

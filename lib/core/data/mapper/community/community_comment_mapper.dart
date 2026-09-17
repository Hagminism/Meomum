import 'package:meomum/core/data/dto/community/community_comment_dto.dart';
import 'package:meomum/feature/community/domain/model/community_comment.dart';

extension CommunityCommentDtoMapper on CommunityCommentDto {
  CommunityComment toModel({
    String? currentUserId,
    int replyCount = 0,
  }) {
    final profile = profiles;
    final post = posts;
    final upperRegion = profile?['upper_region'];
    final lowerRegion = profile?['lower_region'];
    final region = [
      upperRegion,
      lowerRegion,
    ].whereType<String>().where((String value) => value.isNotEmpty).join(' ');
    final likes = commentLikes.whereType<Map<String, dynamic>>();

    return CommunityComment(
      id: id,
      postId: postId,
      parentId: parentId,
      authorId: authorId,
      nickname: profile?['nickname'] as String? ?? '동네이웃',
      neighborhood: region.isEmpty ? '동네이웃' : region,
      profileImageUrl: profile?['profile_image_url'] as String?,
      content: content,
      storagePath: storagePath,
      imageUrl: imageUrl,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      likeCount: likeCount,
      isLiked:
          currentUserId != null &&
          likes.any((Map<String, dynamic> like) {
            return like['account_id'] == currentUserId;
          }),
      isDeleted: isDeleted,
      replyCount: replyCount,
      postTitle: post?['title'] as String? ?? '',
      postCategory: post?['category'] as String? ?? '',
    );
  }
}

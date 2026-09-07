import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class ShareService {
  Future<ShareResult> sharePost({
    required CommunityPost post,
  });
}

class ShareServiceImpl implements ShareService {
  @override
  Future<ShareResult> sharePost({
    required CommunityPost post,
  }) async {
    return SharePlus.instance.share(
      ShareParams(
        title: '머뭄 게시글 공유',
        subject: post.title,
        text: _buildShareText(post),
      ),
    );
  }

  String _buildShareText(CommunityPost post) {
    return '[머뭄] ${_boardLabel(post)} · '
        '${post.upperRegion} ${post.lowerRegion}\n\n'
        '${post.title}\n\n'
        '${post.content}';
  }

  String _boardLabel(CommunityPost post) {
    if (post.category.name == 'free') {
      return '자유게시판';
    }
    return '${post.category.label} 게시판';
  }
}

final shareServiceProvider = Provider<ShareService>((Ref ref) {
  return ShareServiceImpl();
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/presentation/service/share_service.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class SharePostHandler {
  Future<void> sharePost({
    required CommunityPost post,
    required BuildContext shareContext,
  });
}

class SharePostHandlerImpl implements SharePostHandler {
  final ShareService _shareService;

  SharePostHandlerImpl(this._shareService);

  @override
  Future<void> sharePost({
    required CommunityPost post,
    required BuildContext shareContext,
  }) async {
    try {
      final result = await _shareService.sharePost(
        post: post,
      );

      if (!shareContext.mounted ||
          result.status != ShareResultStatus.unavailable) {
        return;
      }

      AppSnackBar.showError(shareContext, '공유할 수 있는 앱이 없습니다.');
    } catch (error) {
      if (!shareContext.mounted) return;
      AppSnackBar.showError(shareContext, '공유 중 오류가 발생했습니다: $error');
    }
  }
}

final sharePostHandlerProvider = Provider<SharePostHandler>((Ref ref) {
  return SharePostHandlerImpl(ref.read(shareServiceProvider));
});

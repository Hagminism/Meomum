import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/presentation/service/share_post_handler.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_action.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_event.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_screen.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_view_model.dart';

class CommunityPostDetailScreenRoot extends ConsumerStatefulWidget {
  final String postId;

  const CommunityPostDetailScreenRoot({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<CommunityPostDetailScreenRoot> createState() =>
      _CommunityPostDetailScreenRootState();
}

class _CommunityPostDetailScreenRootState
    extends ConsumerState<CommunityPostDetailScreenRoot> {
  StreamSubscription<CommunityPostDetailEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = ref.read(
        communityPostDetailViewModelProvider(widget.postId).notifier,
      );
      _eventSubscription = viewModel.eventStream.listen((event) {
        if (!mounted) return;

        switch (event) {
          case ShowMessage(:final message):
            AppSnackBar.showInfo(context, message);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      communityPostDetailViewModelProvider(widget.postId),
    );
    final viewModel = ref.read(
      communityPostDetailViewModelProvider(widget.postId).notifier,
    );

    return CommunityPostDetailScreen(
      state: state,
      onShare: (BuildContext shareContext) {
        final post = state.post;
        if (post != null) {
          ref
              .read(sharePostHandlerProvider)
              .sharePost(
                post: post,
                shareContext: shareContext,
              );
        }
      },
      onAction: (CommunityPostDetailAction action) {
        switch (action) {
          case TapBack():
            context.pop();
            break;
          case ToggleLike():
          case ChangeComment():
          case PickImage():
          case SubmitComment():
            viewModel.onAction(action);
            break;
          case TapMenu(:final item):
            if (item == CommunityPostDetailMenuItem.report) {
              _openReport();
              break;
            }
            viewModel.onAction(action);
            break;
        }
      },
    );
  }

  Future<void> _openReport() async {
    final currentPath = GoRouterState.of(context).uri.path;
    final didSubmit = await context.push<bool>(
      '$currentPath/${Routes.report}',
    );
    if (!mounted || didSubmit != true) return;

    AppSnackBar.showSuccess(context, '신고가 접수되었습니다.');
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}

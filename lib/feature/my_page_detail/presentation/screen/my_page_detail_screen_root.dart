import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/presentation/service/share_post_handler.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_action.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_event.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_screen.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_view_model.dart';

class MyPageDetailScreenRoot extends ConsumerStatefulWidget {
  const MyPageDetailScreenRoot({super.key});

  @override
  ConsumerState<MyPageDetailScreenRoot> createState() =>
      _MyPageDetailScreenRootState();
}

class _MyPageDetailScreenRootState
    extends ConsumerState<MyPageDetailScreenRoot> {
  StreamSubscription<MyPageDetailEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = ref.read(myPageDetailViewModelProvider.notifier);
      _eventSubscription = viewModel.eventStream.listen(
        (MyPageDetailEvent event) {
          if (!mounted) return;

          switch (event) {
            case ShowError(:final message):
              AppSnackBar.showError(context, message);
            case ShowMessage(:final message):
              AppSnackBar.showInfo(context, message);
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myPageDetailViewModelProvider);
    final viewModel = ref.read(myPageDetailViewModelProvider.notifier);

    return MyPageDetailScreen(
      state: state,
      onRefresh: viewModel.refresh,
      onShare: (CommunityPost post, BuildContext shareContext) {
        ref
            .read(sharePostHandlerProvider)
            .sharePost(post: post, shareContext: shareContext);
      },
      onAction: (MyPageDetailAction action) {
        switch (action) {
          case TapBack():
            context.pop();
            break;
          case TapPost(:final postId):
            context.push(
              '${Routes.myPage}/${Routes.myPageFeed}/post-detail/$postId',
            );
            break;
          case TapEditProfile():
            _openEditProfile();
            break;
          case SelectTab():
          case ChangeImagePage():
          case ToggleLike():
          case TapComment():
          case LoadMore():
          case Refresh():
            viewModel.onAction(action);
            break;
        }
      },
    );
  }

  Future<void> _openEditProfile() async {
    final result = await context.push<bool>(
      '${Routes.myPage}/${Routes.myPageFeed}/${Routes.myPageFeedEditProfile}',
    );

    if (!mounted || result != true) return;
    ref.read(myPageDetailViewModelProvider.notifier).refreshUser();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}

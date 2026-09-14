import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/presentation/component/dialog/two_button_dialog/two_button_dialog.dart';
import 'package:meomum/core/presentation/service/share_post_handler.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_action.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_event.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_screen.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_view_model.dart';

class HomePostDetailScreenRoot extends ConsumerStatefulWidget {
  final String postId;

  const HomePostDetailScreenRoot({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<HomePostDetailScreenRoot> createState() =>
      _HomePostDetailScreenRootState();
}

class _HomePostDetailScreenRootState
    extends ConsumerState<HomePostDetailScreenRoot> {
  StreamSubscription<HomePostDetailEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = ref.read(
        homePostDetailViewModelProvider(widget.postId).notifier,
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
    final state = ref.watch(homePostDetailViewModelProvider(widget.postId));
    final viewModel = ref.read(
      homePostDetailViewModelProvider(widget.postId).notifier,
    );

    return HomePostDetailScreen(
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
      onAction: (HomePostDetailAction action) {
        switch (action) {
          case TapBack():
            if (!state.isDeleting) {
              context.pop();
            }
            break;
          case ToggleLike():
          case ChangeComment():
          case PickImage():
          case SubmitComment():
            viewModel.onAction(action);
            break;
          case TapMenu(:final item):
            if (item == HomePostDetailMenuItem.report) {
              _openReport();
              break;
            }
            if (item == HomePostDetailMenuItem.edit) {
              _openEdit(viewModel);
              break;
            }
            unawaited(_confirmDelete(viewModel));
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

  Future<void> _openEdit(HomePostDetailViewModel viewModel) async {
    final currentPath = GoRouterState.of(context).uri.path;
    final didUpdate = await context.push<bool>(
      '$currentPath/${Routes.postEdit}',
    );
    if (!mounted || didUpdate != true) return;

    await viewModel.refresh();
    if (mounted) {
      AppSnackBar.showSuccess(context, '게시글이 수정되었습니다.');
    }
  }

  Future<void> _confirmDelete(HomePostDetailViewModel viewModel) async {
    final shouldDelete = await TwoButtonDialog.show(
      context,
      title: '게시글을 삭제하시겠습니까?',
      message: '삭제한 게시글은 복구할 수 없습니다.',
      cancelLabel: '취소',
      confirmLabel: '삭제',
    );
    if (!mounted || !shouldDelete) return;

    final result = await viewModel.deletePost();
    if (!mounted) return;

    switch (result) {
      case Success():
        context.pop(true);
      case Failure(message: final message):
        AppSnackBar.showError(context, message);
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}

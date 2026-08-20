import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/presentation/screen/community_view_model.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_action.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_event.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_screen.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_view_model.dart';

class CommunityWriteScreenRoot extends ConsumerStatefulWidget {
  const CommunityWriteScreenRoot({super.key});

  @override
  ConsumerState<CommunityWriteScreenRoot> createState() =>
      _CommunityWriteScreenRootState();
}

class _CommunityWriteScreenRootState
    extends ConsumerState<CommunityWriteScreenRoot> {
  StreamSubscription<CommunityWriteEvent>? _subscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(communityWriteViewModelProvider.notifier);

      _subscription = viewModel.eventStream.listen((event) async {
        if (!mounted) return;

        switch (event) {
          case PostCreatedSuccess(:final post):
            ref.read(communityViewModelProvider.notifier).addPost(post);

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('게시글이 등록되었습니다.')));

            context.pop();
            break;
          case ShowMessage(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            break;
          case Pop():
            context.pop();
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityWriteViewModelProvider);
    final viewModel = ref.read(communityWriteViewModelProvider.notifier);

    return CommunityWriteScreen(
      state: state,
      onAction: (action) async {
        switch (action) {
          case TapLocationSearch():
            final selectedPlace = await context.push<CommunityPlace>(
              '${Routes.community}/${Routes.communityWrite}/${Routes.communityLocationSearch}',
            );
            if (selectedPlace != null && mounted) {
              ref
                  .read(communityWriteViewModelProvider.notifier)
                  .onAction(CommunityWriteAction.setLocation(selectedPlace));
            }
            break;
          case SelectCategory():
          case PickMedia():
          case RemoveMedia():
          case SetLocation():
          case ChangeTitle():
          case ChangeContent():
          case TapUpload():
          case TapBack():
            viewModel.onAction(action);
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

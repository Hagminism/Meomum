import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_event.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_screen.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_view_model.dart';

class MyPageScreenRoot extends ConsumerStatefulWidget {
  const MyPageScreenRoot({super.key});

  @override
  ConsumerState<MyPageScreenRoot> createState() => _MyPageScreenRootState();
}

class _MyPageScreenRootState extends ConsumerState<MyPageScreenRoot> {
  StreamSubscription<MyPageEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(myPageViewModelProvider.notifier);

      _eventSubscription = viewModel.eventStream.listen((MyPageEvent event) {
        if (!mounted) {
          return;
        }

        switch (event) {
          case ShowError(:final message):
            AppSnackBar.showError(context, message);
          case ShowMessage(:final message):
            AppSnackBar.showInfo(context, message);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myPageViewModelProvider);
    final viewModel = ref.read(myPageViewModelProvider.notifier);

    return MyPageScreen(
      state: state,
      onAction: (MyPageAction action) {
        switch (action) {
          case TapMyFeed():
            context.push('${Routes.myPage}/${Routes.myPageFeed}');
            break;
          case TapProfile():
          case TapCurrentStayMenu():
          case TapStayHistory():
          case TapStayHistoryMenu():
          case TapLogout():
            viewModel.onAction(action);
            break;
          case TapCategory(:final id):
            final category = CommunityCategory.values.firstWhere(
              (CommunityCategory category) => category.name == id,
              orElse: () {
                return CommunityCategory.free;
              },
            );
            final location = Uri(
              path: Routes.community,
              queryParameters: {
                Routes.communityCategoryQuery: category.name,
              },
            ).toString();

            context.go(location);
            break;
          case TapSettings():
            // TODO: 설정 페이지 이동은 나중에 구현
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/home/presentation/screen/home_action.dart';
import 'package:meomum/feature/home/presentation/screen/home_event.dart';
import 'package:meomum/feature/home/presentation/screen/home_screen.dart';
import 'package:meomum/feature/home/presentation/screen/home_view_model.dart';

class HomeScreenRoot extends ConsumerStatefulWidget {
  const HomeScreenRoot({super.key});

  @override
  ConsumerState<HomeScreenRoot> createState() => _HomeScreenRootState();
}

class _HomeScreenRootState extends ConsumerState<HomeScreenRoot> {
  StreamSubscription<HomeEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(homeViewModelProvider.notifier);

      _eventSubscription = viewModel.eventStream.listen((HomeEvent event) {
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
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return HomeScreen(
      state: state,
      onRefresh: viewModel.refresh,
      onAction: (HomeAction action) {
        switch (action) {
          case TapFeedItem(:final id):
            context.push('${Routes.home}/post-detail/$id');
            break;
          case ChangeBannerIndex():
          case LoadMore():
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

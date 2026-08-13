import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
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
      onAction: (HomeAction action) {
        switch (action) {
          case ChangeBannerIndex():
          case TapCategory():
          case TapFeedItem():
            viewModel.onAction(action);
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

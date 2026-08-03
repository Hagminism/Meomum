import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
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
          case TapLogout():
            viewModel.onAction(action);
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

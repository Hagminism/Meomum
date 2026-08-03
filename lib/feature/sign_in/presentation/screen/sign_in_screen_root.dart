import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_action.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_event.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_screen.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_view_model.dart';

class SignInScreenRoot extends ConsumerStatefulWidget {
  const SignInScreenRoot({super.key});

  @override
  ConsumerState<SignInScreenRoot> createState() => _SignInScreenRootState();
}

class _SignInScreenRootState extends ConsumerState<SignInScreenRoot> {
  StreamSubscription<SignInEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(signInViewModelProvider.notifier);

      _eventSubscription = viewModel.eventStream.listen((SignInEvent event) {
        if (!mounted) {
          return;
        }

        switch (event) {
          case ShowError(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
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
    final state = ref.watch(signInViewModelProvider);
    final viewModel = ref.read(signInViewModelProvider.notifier);

    return SignInScreen(
      state: state,
      onAction: (SignInAction action) {
        switch (action) {
          case TapGoogle():
          case TapApple():
          case TapKakao():
          case TapNaver():
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

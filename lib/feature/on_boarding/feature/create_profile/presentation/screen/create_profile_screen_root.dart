import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_action.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_event.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_screen.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_view_model.dart';

class CreateProfileScreenRoot extends ConsumerStatefulWidget {
  const CreateProfileScreenRoot({super.key});

  @override
  ConsumerState<CreateProfileScreenRoot> createState() =>
      _CreateProfileScreenRootState();
}

class _CreateProfileScreenRootState
    extends ConsumerState<CreateProfileScreenRoot> {
  StreamSubscription<CreateProfileEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = ref.read(createProfileViewModelProvider.notifier);
      _eventSubscription = viewModel.eventStream.listen(
        (CreateProfileEvent event) {
          if (!mounted) return;

          switch (event) {
            case ShowError(:final message):
              AppSnackBar.showError(context, message);
            case ProfileSaved():
              context.push(
                '${Routes.onBoarding}/${Routes.onBoardingSelectRegion}',
              );
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createProfileViewModelProvider);
    final viewModel = ref.read(createProfileViewModelProvider.notifier);

    return CreateProfileScreen(
      state: state,
      onAction: (CreateProfileAction action) {
        switch (action) {
          case TapBack():
            context.pop();
          case TapAvatar():
          case ChangeNickname():
          case TapSubmit():
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

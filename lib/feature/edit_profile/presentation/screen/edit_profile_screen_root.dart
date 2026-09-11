import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/feature/edit_profile/presentation/screen/edit_profile_action.dart';
import 'package:meomum/feature/edit_profile/presentation/screen/edit_profile_event.dart';
import 'package:meomum/feature/edit_profile/presentation/screen/edit_profile_screen.dart';
import 'package:meomum/feature/edit_profile/presentation/screen/edit_profile_view_model.dart';

class EditProfileScreenRoot extends ConsumerStatefulWidget {
  const EditProfileScreenRoot({super.key});

  @override
  ConsumerState<EditProfileScreenRoot> createState() =>
      _EditProfileScreenRootState();
}

class _EditProfileScreenRootState extends ConsumerState<EditProfileScreenRoot> {
  StreamSubscription<EditProfileEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = ref.read(editProfileViewModelProvider.notifier);
      _eventSubscription = viewModel.eventStream.listen(
        (EditProfileEvent event) {
          if (!mounted) return;

          switch (event) {
            case ShowError(:final message):
              AppSnackBar.showError(context, message);
            case ProfileSaved():
              context.pop(true);
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileViewModelProvider);
    final viewModel = ref.read(editProfileViewModelProvider.notifier);

    return EditProfileScreen(
      state: state,
      onAction: (EditProfileAction action) {
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

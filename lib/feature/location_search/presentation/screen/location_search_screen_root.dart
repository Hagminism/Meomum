import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/feature/location_search/presentation/screen/location_search_action.dart';
import 'package:meomum/feature/location_search/presentation/screen/location_search_event.dart';
import 'package:meomum/feature/location_search/presentation/screen/location_search_screen.dart';
import 'package:meomum/feature/location_search/presentation/screen/location_search_view_model.dart';

class LocationSearchScreenRoot extends ConsumerStatefulWidget {
  const LocationSearchScreenRoot({super.key});

  @override
  ConsumerState<LocationSearchScreenRoot> createState() =>
      _LocationSearchScreenRootState();
}

class _LocationSearchScreenRootState
    extends ConsumerState<LocationSearchScreenRoot> {
  StreamSubscription<LocationSearchEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscription = ref
          .read(locationSearchViewModelProvider.notifier)
          .eventStream
          .listen((event) {
            if (!mounted) return;
            switch (event) {
              case PopWithPlace(:final place):
                context.pop(place);
              case Pop():
                context.pop();
              case ShowMessage(:final message):
                AppSnackBar.showInfo(context, message);
            }
          });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationSearchViewModelProvider);
    final viewModel = ref.read(locationSearchViewModelProvider.notifier);

    return LocationSearchScreen(
      state: state,
      onAction: (action) {
        switch (action) {
          case ChangeQuery():
            viewModel.onAction(action);
          case Search():
            viewModel.onAction(action);
          case SelectPlace():
            viewModel.onAction(action);
          case TapBack():
            viewModel.onAction(action);
        }
      },
    );
  }
}

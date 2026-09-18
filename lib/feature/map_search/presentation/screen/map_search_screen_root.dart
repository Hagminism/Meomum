import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_action.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_screen.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_view_model.dart';

class MapSearchScreenRoot extends ConsumerWidget {
  const MapSearchScreenRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapSearchViewModelProvider);
    final viewModel = ref.read(mapSearchViewModelProvider.notifier);

    return MapSearchScreen(
      state: state,
      onStoreSelected: (CommercialStore store) {
        context.push(Routes.storeDetailLocation(store));
      },
      onAction: (action) {
        switch (action) {
          case QueryChanged():
          case SearchSubmitted():
          case RetryPressed():
            viewModel.onAction(action);
          case BackPressed():
            context.pop();
        }
      },
    );
  }
}

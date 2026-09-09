import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/feature/report/presentation/screen/report_action.dart';
import 'package:meomum/feature/report/presentation/screen/report_event.dart';
import 'package:meomum/feature/report/presentation/screen/report_screen.dart';
import 'package:meomum/feature/report/presentation/screen/report_view_model.dart';

class ReportScreenRoot extends ConsumerStatefulWidget {
  final String postId;

  const ReportScreenRoot({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ReportScreenRoot> createState() => _ReportScreenRootState();
}

class _ReportScreenRootState extends ConsumerState<ReportScreenRoot> {
  StreamSubscription<ReportEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = ref.read(
        reportViewModelProvider(widget.postId).notifier,
      );
      _eventSubscription = viewModel.eventStream.listen((event) {
        if (!mounted) return;

        switch (event) {
          case Submitted():
            context.pop(true);
          case ShowMessage(:final message):
            AppSnackBar.showInfo(context, message);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportViewModelProvider(widget.postId));
    final viewModel = ref.read(reportViewModelProvider(widget.postId).notifier);

    return ReportScreen(
      state: state,
      onAction: (ReportAction action) {
        switch (action) {
          case TapBack():
            context.pop();
            break;
          case RetryPost():
          case ChangeTitle():
          case ChangeContent():
          case PickPhotos():
          case RemovePhoto():
          case Submit():
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

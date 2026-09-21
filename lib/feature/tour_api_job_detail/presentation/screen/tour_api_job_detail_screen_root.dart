import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/feature/tour_api_job_detail/presentation/screen/tour_api_job_detail_action.dart';
import 'package:meomum/feature/tour_api_job_detail/presentation/screen/tour_api_job_detail_screen.dart';
import 'package:meomum/feature/tour_api_job_detail/presentation/screen/tour_api_job_detail_state.dart';
import 'package:meomum/feature/tour_api_job_detail/presentation/screen/tour_api_job_detail_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class TourApiJobDetailScreenRoot extends ConsumerWidget {
  final String empmnInfoNo;

  const TourApiJobDetailScreenRoot({
    super.key,
    required this.empmnInfoNo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = tourApiJobDetailViewModelProvider(empmnInfoNo);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    return TourApiJobDetailScreen(
      state: state,
      onAction: (TourApiJobDetailAction action) {
        switch (action) {
          case TapBack():
            context.pop();
          case TapRetryDetail():
            viewModel.onAction(action);
          case TapOriginalLink():
            unawaited(_openOriginalLink(context, state));
        }
      },
    );
  }

  Future<void> _openOriginalLink(
    BuildContext context,
    TourApiJobDetailState state,
  ) async {
    final url =
        state.posting?.originalUrl ??
        state.detail?['tursmEmpmnInfoURL']?.toString();
    if (url == null || url.isEmpty) return;
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      AppSnackBar.showError(context, '원문 링크를 열지 못했습니다.');
    }
  }
}

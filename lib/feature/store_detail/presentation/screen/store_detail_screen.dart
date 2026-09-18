import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/store_detail/presentation/component/store_detail_web_view.dart';
import 'package:meomum/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:meomum/feature/store_detail/presentation/screen/store_detail_state.dart';
import 'package:meomum/ui/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StoreDetailScreen extends StatelessWidget {
  final CommercialStore store;
  final WebViewController webViewController;
  final StoreDetailState state;
  final void Function(StoreDetailAction action) onAction;

  const StoreDetailScreen({
    super.key,
    required this.store,
    required this.webViewController,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        onAction(const StoreDetailAction.tapBack());
      },
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        appBar: CustomAppBar(
          title: store.displayName,
          toolbarHeight: 54,
          showBackButton: true,
          backButtonTooltip: '이전 화면으로 돌아가기',
          onBackPressed: () {
            onAction(const StoreDetailAction.tapBack());
          },
          trailing: IconButton(
            onPressed: () {
              onAction(const StoreDetailAction.tapNaverMap());
            },
            tooltip: '네이버 지도에서 열기',
            icon: const Icon(Icons.map_outlined, size: 22),
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: StoreDetailWebView(
            controller: webViewController,
            isLoading: state.isWebViewLoading,
            hasError: state.hasWebViewError,
            progress: state.webViewProgress,
            onRetryPressed: () {
              onAction(const StoreDetailAction.tapRetry());
            },
          ),
        ),
      ),
    );
  }
}

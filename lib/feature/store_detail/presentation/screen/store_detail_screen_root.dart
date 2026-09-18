import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:meomum/feature/store_detail/presentation/screen/store_detail_view_model.dart';
import 'package:meomum/feature/store_detail/presentation/screen/store_detail_screen.dart';
import 'package:meomum/ui/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StoreDetailScreenRoot extends ConsumerStatefulWidget {
  final CommercialStore store;

  const StoreDetailScreenRoot({
    super.key,
    required this.store,
  });

  @override
  ConsumerState<StoreDetailScreenRoot> createState() =>
      _StoreDetailScreenRootState();
}

class _StoreDetailScreenRootState extends ConsumerState<StoreDetailScreenRoot> {
  static const int _cancelledNavigationErrorCode = -999;

  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    final viewModel = ref.read(storeDetailViewModelProvider.notifier);
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: viewModel.onProgress,
          onPageStarted: (_) => viewModel.onPageStarted(),
          onPageFinished: (_) => viewModel.onPageFinished(),
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame != true ||
                error.errorCode == _cancelledNavigationErrorCode) {
              return;
            }
            viewModel.onMainFrameError();
          },
        ),
      )
      ..loadRequest(_naverSearchUri);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(storeDetailViewModelProvider.notifier);
    final state = ref.watch(storeDetailViewModelProvider);

    return StoreDetailScreen(
      store: widget.store,
      webViewController: _webViewController,
      state: state,
      onAction: (action) async {
        switch (action) {
          case TapBack():
            await _handleBackAction();
          case TapNaverMap():
            await _openExternalSearch(_naverMapUri);
          case TapRetry():
            viewModel.onAction(action);
            await _webViewController.reload();
        }
      },
    );
  }

  Uri get _naverSearchUri {
    return Uri.https(
      'search.naver.com',
      '/search.naver',
      {'query': _searchQuery},
    );
  }

  Uri get _naverMapUri {
    return Uri.parse(
      'https://map.naver.com/p/search/${Uri.encodeComponent(_searchQuery)}',
    );
  }

  String get _searchQuery {
    return [
      widget.store.displayName,
      widget.store.address,
    ].where((value) => value?.trim().isNotEmpty ?? false).join(' ');
  }

  Future<void> _handleBackAction() async {
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
      return;
    }

    if (mounted) context.pop();
  }

  Future<void> _openExternalSearch(Uri uri) async {
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted || didLaunch) return;
    AppSnackBar.showError(context, '네이버 지도를 열 수 없습니다.');
  }
}

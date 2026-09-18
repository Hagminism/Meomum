import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StoreDetailWebView extends StatelessWidget {
  final WebViewController controller;
  final bool isLoading;
  final bool hasError;
  final int progress;
  final void Function() onRetryPressed;

  const StoreDetailWebView({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.hasError,
    required this.progress,
    required this.onRetryPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError) return _buildErrorView();

    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (isLoading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              value: progress == 0 ? null : progress / 100,
              backgroundColor: AppColors.divider,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildErrorView() {
    return ColoredBox(
      color: AppColors.homeBackground,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 36,
                color: AppColors.textSecondary,
                semanticLabel: '네이버 검색 연결 실패',
              ),
              const SizedBox(height: 16),
              const Text(
                '네이버 검색 결과를 불러오지 못했습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '네트워크 상태를 확인한 뒤 다시 시도해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onRetryPressed,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

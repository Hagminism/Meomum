import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/ui/app_colors.dart';

class SplashScreen extends StatelessWidget {
  final bool isError;
  final String? errorMessage;
  final void Function()? onRetry;

  const SplashScreen({
    super.key,
    this.isError = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: isError ? _buildErrorView() : _buildLoadingView(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      key: const ValueKey<String>('loading'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/app_logo.png',
              width: 205,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),
            const Text(
              '한달살기인들의 커뮤니티',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0E6927),
              ),
            ),
            const SizedBox(height: 42),
            SizedBox(
              width: 88,
              height: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: const LinearProgressIndicator(
                  backgroundColor: Color(0xFFE3F0E5),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '잠시만 기다려 주세요',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      key: const ValueKey<String>('error'),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          Image.asset(
            'assets/app_logo.png',
            width: 148,
            fit: BoxFit.contain,
          ),
          const Spacer(flex: 3),
          const SizedBox(height: 24),
          const Text(
            '잠시 연결이 필요해요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.56,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage ?? '프로필을 불러오지 못했어요.\n다시 연결해 주세요.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(flex: 4),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 22),
              label: const Text('다시 연결하기'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.uploadButton,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

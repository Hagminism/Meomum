import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

enum AppSnackBarType { success, error, info }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Scaffold가 하단 네비게이션 바와 안전 영역을 자동으로 반영한다.
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 3),
          content: _SnackBarContent(message: message, type: type),
        ),
      );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: AppSnackBarType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: AppSnackBarType.error);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: AppSnackBarType.info);
  }
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final AppSnackBarType type;

  const _SnackBarContent({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      AppSnackBarType.success => Icons.check_circle_rounded,
      AppSnackBarType.error => Icons.error_rounded,
      AppSnackBarType.info => Icons.info_rounded,
    };

    final accentColor = switch (type) {
      AppSnackBarType.success => AppColors.primary,
      AppSnackBarType.error => AppColors.snackBarError,
      AppSnackBarType.info => AppColors.snackBarInfo,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.snackBarSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

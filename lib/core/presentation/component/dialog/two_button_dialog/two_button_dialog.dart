import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/dialog/two_button_dialog/two_button_dialog_content.dart';
import 'package:meomum/ui/app_colors.dart';

class TwoButtonDialog {
  const TwoButtonDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String cancelLabel = '취소',
    String confirmLabel = '확인',
  }) async {
    final shouldConfirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: title,
      barrierColor: AppColors.black.withValues(alpha: 0.56),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder:
          (
            BuildContext dialogContext,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return TwoButtonDialogContent(
              title: title,
              message: message,
              cancelLabel: cancelLabel,
              confirmLabel: confirmLabel,
            );
          },
      transitionBuilder:
          (
            BuildContext transitionContext,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.96,
                  end: 1,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
    );

    return shouldConfirm ?? false;
  }
}

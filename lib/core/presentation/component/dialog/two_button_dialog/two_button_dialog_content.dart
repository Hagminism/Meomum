import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/dialog/two_button_dialog/two_button_dialog_action_button.dart';
import 'package:meomum/ui/app_colors.dart';

class TwoButtonDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;

  const TwoButtonDialogContent({
    super.key,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                color: AppColors.writeBackground,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.inputBorder.withValues(alpha: 0.75),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.16),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: AppColors.communityText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: AppColors.feedContentText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TwoButtonDialogActionButton(
                          label: cancelLabel,
                          color: const Color(0xFFF5F5F6),
                          textColor: const Color(0xFF020202),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TwoButtonDialogActionButton(
                          label: confirmLabel,
                          color: const Color(0xFFFC4748),
                          textColor: AppColors.white,
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

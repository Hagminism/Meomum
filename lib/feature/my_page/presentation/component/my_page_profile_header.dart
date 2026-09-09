import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/user/user.dart';
import 'package:meomum/feature/my_page/presentation/component/my_page_profile_content.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageProfileHeader extends StatelessWidget {
  final User? user;
  final void Function(MyPageAction) onAction;

  const MyPageProfileHeader({
    super.key,
    required this.user,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            onAction(const MyPageAction.tapMyFeed());
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: MyPageProfileContent(user: user)),
                const SizedBox(width: 8),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '내 피드',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1,
                        color: AppColors.black,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 24,
                      color: AppColors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

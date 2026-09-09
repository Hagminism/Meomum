import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/user/user.dart';
import 'package:meomum/feature/my_page/presentation/component/my_page_profile_content.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_action.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageDetailProfileHeader extends StatelessWidget {
  final User? user;
  final void Function(MyPageDetailAction) onAction;

  const MyPageDetailProfileHeader({
    super.key,
    required this.user,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(child: MyPageProfileContent(user: user)),
          const SizedBox(width: 8),
          Material(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                onAction(const MyPageDetailAction.tapEditProfile());
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.black,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '프로필 편집',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

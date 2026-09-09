import 'package:flutter/material.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/model/user/user.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageProfileContent extends StatelessWidget {
  final User? user;

  const MyPageProfileContent({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final nickname = user?.nickname ?? '사용자';
    final email = user?.email ?? '';
    final authProvider = user?.authProvider;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.profileAvatarPlaceholder,
          backgroundImage: user?.avatarUrl != null
              ? NetworkImage(user!.avatarUrl!)
              : null,
          child: user?.avatarUrl == null
              ? Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.black.withValues(alpha: 0.3),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        height: 1,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (authProvider == AuthProvider.naver) ...[
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.signUpWithNaverButton,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Image.asset('assets/icons/naver.png'),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        color: AppColors.feedContentText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/ui/app_colors.dart';

class SocialSignInButton extends StatelessWidget {
  final AuthProvider authProvider;
  final void Function() onTap;

  const SocialSignInButton({
    super.key,
    required this.authProvider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: buildColor(authProvider),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 2),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildIcon(authProvider),
              SizedBox(width: (authProvider == AuthProvider.naver) ? 2 : 10),
              buildText(authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Color buildColor(AuthProvider authProvider) {
    switch (authProvider) {
      case AuthProvider.google:
        return AppColors.signUpWithGoogleButton;
      case AuthProvider.naver:
        return AppColors.signUpWithNaverButton;
      case AuthProvider.kakao:
        return AppColors.signUpWithKakaoButton;
    }
  }

  Color buildTextColor(AuthProvider authProvider) {
    switch (authProvider) {
      case AuthProvider.google:
        return AppColors.black;
      case AuthProvider.naver:
        return AppColors.white;
      case AuthProvider.kakao:
        return AppColors.black;
    }
  }

  Widget buildIcon(AuthProvider authProvider) {
    switch (authProvider) {
      case AuthProvider.google:
        return Image.asset(
          'assets/icons/google.png',
          width: 22,
          height: 22,
        );
      case AuthProvider.naver:
        return Image.asset(
          'assets/icons/naver.png',
          width: 36,
          height: 36,
        );
      case AuthProvider.kakao:
        return Image.asset(
          'assets/icons/kakao.png',
          width: 22,
          height: 22,
        );
    }
  }

  Widget buildText(AuthProvider authProvider) {
    final title = '${authProvider.toDisplayName()}로 시작하기';

    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: buildTextColor(authProvider),
      ),
    );
  }
}

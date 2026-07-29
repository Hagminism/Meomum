import 'package:flutter/material.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/ui/app_colors.dart';

class SocialSignInButton extends StatelessWidget {
  final AuthProvider authProvider;
  final void Function() onTap;

  static const String googleAsset = 'assets/icons/google.png';
  static const String appleAsset = 'assets/icons/apple.png';
  static const String naverAsset = 'assets/icons/naver.png';
  static const String kakaoAsset = 'assets/icons/kakao.png';

  const SocialSignInButton({
    super.key,
    required this.authProvider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(90),
        child: Ink(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: buildColor(authProvider),
            borderRadius: BorderRadius.circular(90),
          ),
          child: Center(
            child: Image.asset(
              width: (authProvider == AuthProvider.naver) ? 48 : 36,
              height: (authProvider == AuthProvider.naver) ? 48 : 36,
              buildAsset(authProvider),
            ),
          ),
        ),
      ),
    );
  }

  Color buildColor(AuthProvider authProvider) {
    switch (authProvider) {
      case AuthProvider.google:
        return AppColors.signUpWithGoogleButton;
      case AuthProvider.apple:
        return AppColors.signUpWithAppleButton;
      case AuthProvider.naver:
        return AppColors.signUpWithNaverButton;
      case AuthProvider.kakao:
        return AppColors.signUpWithKakaoButton;
    }
  }

  String buildAsset(AuthProvider authProvider) {
    switch (authProvider) {
      case AuthProvider.google:
        return googleAsset;
      case AuthProvider.apple:
        return appleAsset;
      case AuthProvider.naver:
        return naverAsset;
      case AuthProvider.kakao:
        return kakaoAsset;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/utils/ui_constants.dart';
import 'package:meomum/feature/sign_in/presentation/component/social_sign_in_button.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_action.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_state.dart';
import 'package:meomum/ui/app_colors.dart';

class SignInScreen extends StatelessWidget {
  final SignInState state;
  final void Function(SignInAction) onAction;

  const SignInScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  36,
                  screenHeight * UIConstants.signInTopPaddingRatio,
                  36,
                  screenHeight * UIConstants.signInBottomPaddingRatio,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Image.asset(
                          'assets/app_logo.png',
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '한달살기인들의 커뮤니티',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0E6927),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SocialSignInButton(
                          authProvider: AuthProvider.kakao,
                          onTap: () {
                            onAction(const SignInAction.tapKakao());
                          },
                        ),
                        const SizedBox(height: 20),
                        SocialSignInButton(
                          authProvider: AuthProvider.naver,
                          onTap: () {
                            onAction(const SignInAction.tapNaver());
                          },
                        ),
                        const SizedBox(height: 20),
                        SocialSignInButton(
                          authProvider: AuthProvider.google,
                          onTap: () {
                            onAction(const SignInAction.tapGoogle());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (state.isLoading)
          ColoredBox(
            color: AppColors.black.withValues(alpha: 0.3),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('로그인 화면')),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SocialSignInButton(
                    authProvider: AuthProvider.google,
                    onTap: () {
                      onAction(const SignInAction.tapGoogle());
                    },
                  ),
                  SocialSignInButton(
                    authProvider: AuthProvider.apple,
                    onTap: () {
                      onAction(const SignInAction.tapApple());
                    },
                  ),
                  SocialSignInButton(
                    authProvider: AuthProvider.naver,
                    onTap: () {
                      onAction(const SignInAction.tapNaver());
                    },
                  ),
                  SocialSignInButton(
                    authProvider: AuthProvider.kakao,
                    onTap: () {
                      onAction(const SignInAction.tapKakao());
                    },
                  ),
                ],
              ),
            ),
            if (state.isLoading)
              ColoredBox(
                color: AppColors.black.withValues(alpha: 0.3),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

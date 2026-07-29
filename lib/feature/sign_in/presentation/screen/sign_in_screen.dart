import 'package:flutter/material.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/feature/sign_in/presentation/component/social_sign_in_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인 화면')),
      body: SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SocialSignInButton(
                authProvider: AuthProvider.google,
                onTap: () {},
              ),
              SocialSignInButton(
                authProvider: AuthProvider.apple,
                onTap: () {},
              ),
              SocialSignInButton(
                authProvider: AuthProvider.naver,
                onTap: () {},
              ),
              SocialSignInButton(
                authProvider: AuthProvider.kakao,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

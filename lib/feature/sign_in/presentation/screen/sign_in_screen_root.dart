import 'package:flutter/material.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_screen.dart';

class SignInScreenRoot extends StatefulWidget {
  const SignInScreenRoot({super.key});

  @override
  State<SignInScreenRoot> createState() => _SignInScreenRootState();
}

class _SignInScreenRootState extends State<SignInScreenRoot> {
  @override
  Widget build(BuildContext context) {
    return const SignInScreen();
  }
}

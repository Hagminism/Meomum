import 'package:flutter/material.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: SignInScreen(), // 임시 진입부
    );
  }
}

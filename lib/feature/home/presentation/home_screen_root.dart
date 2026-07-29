import 'package:flutter/material.dart';
import 'package:meomum/feature/home/presentation/home_screen.dart';

class HomeScreenRoot extends StatefulWidget {
  const HomeScreenRoot({super.key});

  @override
  State<HomeScreenRoot> createState() => _HomeScreenRootState();
}

class _HomeScreenRootState extends State<HomeScreenRoot> {
  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

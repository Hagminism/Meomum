import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/di/di.dart';
import 'package:meomum/feature/home/presentation/screen/home_screen.dart';

class HomeScreenRoot extends ConsumerWidget {
  const HomeScreenRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(supabaseClientProvider).auth.currentUser;
    return HomeScreen(user: user);
  }
}

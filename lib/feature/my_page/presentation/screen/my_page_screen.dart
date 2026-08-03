import 'package:flutter/material.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_state.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageScreen extends StatelessWidget {
  final MyPageState state;
  final void Function(MyPageAction) onAction;

  const MyPageScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        onAction(const MyPageAction.tapLogout());
                      },
                child: const Text('로그아웃'),
              ),
            ),
            if (state.isLoading)
              ColoredBox(
                color: AppColors.black.withValues(alpha: 0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

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

  static const int _demoItemCount = 30;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 72;

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: Stack(
        children: [
          ListView.separated(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset),
            itemCount: _demoItemCount + 1,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 8);
            },
            itemBuilder: (BuildContext context, int index) {
              if (index == _demoItemCount) {
                return ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          onAction(const MyPageAction.tapLogout());
                        },
                  child: const Text('로그아웃'),
                );
              }

              return ListTile(
                tileColor: AppColors.black.withValues(alpha: 0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.black.withValues(alpha: 0.08),
                  child: Text('${index + 1}'),
                ),
                title: Text('마이페이지 항목 ${index + 1}'),
                subtitle: const Text('바텀 바 반투명 효과 확인용 더미 항목'),
              );
            },
          ),
          if (state.isLoading)
            ColoredBox(
              color: AppColors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

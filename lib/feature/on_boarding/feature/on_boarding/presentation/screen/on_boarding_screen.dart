import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/feature/on_boarding/feature/on_boarding/presentation/screen/on_boarding_action.dart';
import 'package:meomum/ui/app_colors.dart';

class OnBoardingScreen extends StatelessWidget {
  final void Function(OnBoardingAction) onAction;

  const OnBoardingScreen({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: AppColors.black,
                    ),
                    children: [
                      TextSpan(
                        text: '머뭄',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      TextSpan(text: '이 처음이시군요!'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '머물고 싶은 지역을 알려주시면\n'
                  '단기 체류 여행객을 위한 지역 커뮤니티에\n'
                  '입장할 수 있어요.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    letterSpacing: -0.36,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () {
                      onAction(const OnBoardingAction.tapCreateProfile());
                    },
                    label: const Text('프로필 만들기'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.uploadButton,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

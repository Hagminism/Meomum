import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_action.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_state.dart';
import 'package:meomum/core/presentation/component/profile_editor.dart';
import 'package:meomum/ui/app_colors.dart';

class CreateProfileScreen extends StatelessWidget {
  final CreateProfileState state;
  final void Function(CreateProfileAction) onAction;

  const CreateProfileScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: ProfileEditor(
                      title: '프로필을 만들어보세요',
                      description:
                          '커뮤니티에서 사용할 프로필을 만들어보세요.\n'
                          '프로필은 커뮤니티에서 다른 사람에게 보여요.',
                      nickname: state.nickname,
                      avatarUrl: state.avatarUrl,
                      selectedImagePath: state.selectedImagePath,
                      isLoading: state.isLoading,
                      isValid: state.isValid,
                      submitLabel: '이 닉네임을 사용할게요',
                      onAvatarTap: () {
                        onAction(const CreateProfileAction.tapAvatar());
                      },
                      onNicknameChanged: (String nickname) {
                        onAction(CreateProfileAction.changeNickname(nickname));
                      },
                      onBack: () {
                        onAction(const CreateProfileAction.tapBack());
                      },
                      onSubmit: () {
                        onAction(const CreateProfileAction.tapSubmit());
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

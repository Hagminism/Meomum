import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/feature/edit_profile/presentation/screen/edit_profile_action.dart';
import 'package:meomum/feature/edit_profile/presentation/screen/edit_profile_state.dart';
import 'package:meomum/core/presentation/component/profile_editor.dart';
import 'package:meomum/ui/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  final EditProfileState state;
  final void Function(EditProfileAction) onAction;

  const EditProfileScreen({
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: ProfileEditor(
                      title: '프로필을 수정해보세요',
                      description:
                          '커뮤니티에서 사용할 프로필을 수정해보세요.\n'
                          '프로필은 커뮤니티에서 다른 사람에게 보여요.',
                      nickname: state.nickname,
                      avatarUrl: state.avatarUrl,
                      selectedImagePath: state.selectedImagePath,
                      isLoading: state.isLoading,
                      isValid: state.isValid,
                      submitLabel: '변경사항을 저장할게요',
                      onAvatarTap: () {
                        onAction(const EditProfileAction.tapAvatar());
                      },
                      onNicknameChanged: (String nickname) {
                        onAction(EditProfileAction.changeNickname(nickname));
                      },
                      onBack: () {
                        onAction(const EditProfileAction.tapBack());
                      },
                      onSubmit: () {
                        onAction(const EditProfileAction.tapSubmit());
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_action.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_state.dart';
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
    final imageProvider = _imageProvider();

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
                const Text(
                  '프로필을 만들어보세요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '커뮤니티에서 사용할 프로필을 만들어보세요.\n'
                  '프로필은 커뮤니티에서 다른 사람에게 보여요.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    letterSpacing: -0.36,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      onAction(const CreateProfileAction.tapAvatar());
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.cardBackground,
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 40,
                                  color: AppColors.hintIcon,
                                )
                              : null,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.unselectedItem,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.homeBackground,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 15,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: state.nickname,
                  maxLength: 20,
                  textInputAction: TextInputAction.done,
                  onChanged: (String nickname) {
                    onAction(
                      CreateProfileAction.changeNickname(nickname),
                    );
                  },
                  decoration: const InputDecoration(
                    hintText: '닉네임을 입력해주세요',
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                onAction(
                                  const CreateProfileAction.tapBack(),
                                );
                              },
                        label: const Text(
                          '뒤로',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.inputBackground,
                          foregroundColor: AppColors.black,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: state.isLoading || !state.isValid
                              ? null
                              : () {
                                  onAction(
                                    const CreateProfileAction.tapSubmit(),
                                  );
                                },
                          label: const Text(
                            '이 닉네임을 사용할게요',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider<Object>? _imageProvider() {
    final selectedImagePath = state.selectedImagePath;
    if (selectedImagePath != null) {
      return FileImage(File(selectedImagePath));
    }

    final avatarUrl = state.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return NetworkImage(avatarUrl);
    }

    return null;
  }
}

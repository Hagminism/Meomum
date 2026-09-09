import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class ProfileEditor extends StatelessWidget {
  final String title;
  final String description;
  final String nickname;
  final String? avatarUrl;
  final String? selectedImagePath;
  final bool isLoading;
  final bool isValid;
  final String submitLabel;
  final void Function() onAvatarTap;
  final void Function(String) onNicknameChanged;
  final void Function() onBack;
  final void Function() onSubmit;

  const ProfileEditor({
    super.key,
    required this.title,
    required this.description,
    required this.nickname,
    required this.avatarUrl,
    required this.selectedImagePath,
    required this.isLoading,
    required this.isValid,
    required this.submitLabel,
    required this.onAvatarTap,
    required this.onNicknameChanged,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = _imageProvider();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 32,
              fontWeight: FontWeight.w600,
              height: 1,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(
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
              onTap: onAvatarTap,
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
            initialValue: nickname,
            maxLength: 20,
            textInputAction: TextInputAction.done,
            onChanged: onNicknameChanged,
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
                  onPressed: isLoading ? null : onBack,
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
                    onPressed: isLoading || !isValid ? null : onSubmit,
                    label: Text(
                      submitLabel,
                      style: const TextStyle(
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ImageProvider<Object>? _imageProvider() {
    if (selectedImagePath != null) {
      return FileImage(File(selectedImagePath!));
    }

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return NetworkImage(avatarUrl!);
    }

    return null;
  }
}

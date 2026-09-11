import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/edit_profile/presentation/screen/edit_profile_action.dart';
import 'package:meomum/feature/edit_profile/presentation/screen/edit_profile_event.dart';
import 'package:meomum/feature/edit_profile/presentation/screen/edit_profile_state.dart';

class EditProfileViewModel extends Notifier<EditProfileState> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  EditProfileState build() {
    ref.onDispose(() => _eventController.close());

    final currentUser = ref.read(authRepositoryProvider).currentUser;
    return EditProfileState(
      nickname: currentUser?.nickname ?? '사용자',
      avatarUrl: currentUser?.avatarUrl,
    );
  }

  final StreamController<EditProfileEvent> _eventController =
      StreamController<EditProfileEvent>.broadcast();

  Stream<EditProfileEvent> get eventStream => _eventController.stream;

  void onAction(EditProfileAction action) {
    switch (action) {
      case TapAvatar():
        _pickImage();
      case ChangeNickname(:final nickname):
        state = state.copyWith(nickname: nickname);
      case TapBack():
        break;
      case TapSubmit():
        _submit();
    }
  }

  /// 갤러리에서 프로필 이미지를 선택하고 편집 상태에 반영합니다.
  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      _selectedImage = File(image.path);
      state = state.copyWith(selectedImagePath: image.path);
    } catch (_) {
      _eventController.add(
        const EditProfileEvent.showError('사진을 선택하지 못했습니다. 다시 시도해주세요.'),
      );
    }
  }

  /// 입력값을 검증하고 변경된 프로필 정보를 저장합니다.
  Future<void> _submit() async {
    if (state.isLoading) return;

    if (!state.isValid) {
      _eventController.add(
        const EditProfileEvent.showError('닉네임은 1자 이상 20자 이하로 입력해주세요.'),
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.updateProfile(
      nickname: state.nickname.trim(),
      profileImage: _selectedImage,
    );

    if (!ref.mounted) return;

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
        _eventController.add(const EditProfileEvent.profileSaved());
      case Failure(message: final message):
        state = state.copyWith(isLoading: false);
        _eventController.add(EditProfileEvent.showError(message));
    }
  }
}

final editProfileViewModelProvider =
    NotifierProvider.autoDispose<EditProfileViewModel, EditProfileState>(
      EditProfileViewModel.new,
    );

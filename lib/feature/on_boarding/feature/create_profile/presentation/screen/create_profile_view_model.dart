import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_action.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_event.dart';
import 'package:meomum/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_state.dart';

class CreateProfileViewModel extends Notifier<CreateProfileState> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  CreateProfileState build() {
    ref.onDispose(() => _eventController.close());

    final currentUser = ref.read(authRepositoryProvider).currentUser;
    return CreateProfileState(
      nickname: currentUser?.nickname ?? '사용자',
      avatarUrl: currentUser?.avatarUrl,
    );
  }

  final StreamController<CreateProfileEvent> _eventController =
      StreamController<CreateProfileEvent>.broadcast();

  Stream<CreateProfileEvent> get eventStream => _eventController.stream;

  void onAction(CreateProfileAction action) {
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
        const CreateProfileEvent.showError('사진을 선택하지 못했습니다. 다시 시도해주세요.'),
      );
    }
  }

  Future<void> _submit() async {
    if (state.isLoading) return;

    if (!state.isValid) {
      _eventController.add(
        const CreateProfileEvent.showError('닉네임은 1자 이상 20자 이하로 입력해주세요.'),
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
        _eventController.add(const CreateProfileEvent.profileSaved());
      case Failure(message: final message):
        state = state.copyWith(isLoading: false);
        _eventController.add(CreateProfileEvent.showError(message));
    }
  }
}

final createProfileViewModelProvider =
    NotifierProvider.autoDispose<CreateProfileViewModel, CreateProfileState>(
      CreateProfileViewModel.new,
    );

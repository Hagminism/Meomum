import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_image.freezed.dart';

@freezed
abstract class ProfileImage with _$ProfileImage {
  const factory ProfileImage({
    required String storagePath,
    required String publicUrl,
  }) = _ProfileImage;
}

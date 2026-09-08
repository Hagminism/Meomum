import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String accountId,
    required String nickname,
    String? profileImageUrl,
    String? upperRegion,
    String? lowerRegion,
  }) = _Profile;

  const Profile._();

  bool get hasSelectedRegion {
    return upperRegion != null && lowerRegion != null;
  }

  bool get hasPartialRegion {
    return (upperRegion == null) != (lowerRegion == null);
  }
}

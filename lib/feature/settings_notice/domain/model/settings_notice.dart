import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_notice.freezed.dart';
part 'settings_notice.g.dart';

@freezed
abstract class SettingsNotice with _$SettingsNotice {
  const factory SettingsNotice({
    required String id,
    required String date,
    required String title,
    required String content,
  }) = _SettingsNotice;

  factory SettingsNotice.fromJson(Map<String, dynamic> json) =>
      _$SettingsNoticeFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/settings_notice/domain/model/settings_notice.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default([]) List<SettingsNotice> notices,
    @Default(false) bool isLoading,
  }) = _SettingsState;
}

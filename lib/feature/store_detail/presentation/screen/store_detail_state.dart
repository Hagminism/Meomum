import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_detail_state.freezed.dart';

@freezed
sealed class StoreDetailState with _$StoreDetailState {
  const factory StoreDetailState({
    @Default(true) bool isWebViewLoading,
    @Default(false) bool hasWebViewError,
    @Default(0) int webViewProgress,
  }) = _StoreDetailState;
}

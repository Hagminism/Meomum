import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/model/user/user.dart';
import 'package:meomum/core/domain/model/category/category.dart';
import 'package:meomum/feature/my_page/domain/model/current_stay.dart';
import 'package:meomum/feature/my_page/domain/model/stay_history_item.dart';

part 'my_page_state.freezed.dart';

@freezed
abstract class MyPageState with _$MyPageState {
  const factory MyPageState({
    User? user,
    CurrentStay? currentStay,
    @Default([]) List<Category> categories,
    @Default([]) List<StayHistoryItem> stayHistories,
    @Default(false) bool isLoading,
  }) = _MyPageState;
}

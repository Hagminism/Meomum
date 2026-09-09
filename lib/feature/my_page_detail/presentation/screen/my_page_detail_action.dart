import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/my_page_detail/domain/model/enum/my_page_feed_tab.dart';

part 'my_page_detail_action.freezed.dart';

@freezed
sealed class MyPageDetailAction with _$MyPageDetailAction {
  const factory MyPageDetailAction.tapBack() = TapBack;
  const factory MyPageDetailAction.selectTab(MyPageFeedTab tab) = SelectTab;
  const factory MyPageDetailAction.changeImagePage(
    String postId,
    int pageIndex,
  ) = ChangeImagePage;
  const factory MyPageDetailAction.toggleLike(String postId) = ToggleLike;
  const factory MyPageDetailAction.tapComment(String postId) = TapComment;
  const factory MyPageDetailAction.tapPost(String postId) = TapPost;
  const factory MyPageDetailAction.tapEditProfile() = TapEditProfile;
  const factory MyPageDetailAction.loadMore() = LoadMore;
  const factory MyPageDetailAction.refresh() = Refresh;
}

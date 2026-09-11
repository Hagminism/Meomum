import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/model/user/user.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/my_page_detail/domain/model/enum/my_page_feed_tab.dart';

part 'my_page_detail_state.freezed.dart';

@freezed
abstract class MyPageDetailState with _$MyPageDetailState {
  const MyPageDetailState._();

  const factory MyPageDetailState({
    User? user,
    @Default(MyPageFeedTab.myPosts) MyPageFeedTab selectedTab,
    @Default([]) List<CommunityPost> posts,
    @Default({}) Map<String, int> imagePageByPostId,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
  }) = _MyPageDetailState;

  bool get isPlaceholderTab => selectedTab != MyPageFeedTab.myPosts;
}

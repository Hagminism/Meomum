import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/my_page_detail/domain/model/enum/my_page_feed_tab.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_action.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_screen.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_state.dart';

void main() {
  testWidgets('좋아요한 글 탭은 좋아요한 게시글을 표시한다', (tester) async {
    final post = CommunityPost(
      id: 'liked-post-id',
      authorId: 'author-id',
      upperRegion: '서울특별시',
      lowerRegion: '중구',
      nickname: '머뭄이',
      createdAt: DateTime(2026, 1, 1),
      category: CommunityCategory.free,
      title: '좋아요한 글 테스트',
      content: '좋아요한 글 본문',
      isLiked: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MyPageDetailScreen(
          state: MyPageDetailState(
            selectedTab: MyPageFeedTab.likedPosts,
            likedPosts: [post],
          ),
          onAction: _onAction,
          onShare: _onShare,
          onRefresh: _onRefresh,
        ),
      ),
    );

    expect(find.text('좋아요한 글 테스트'), findsOneWidget);
    expect(find.text('준비 중인 기능입니다.'), findsNothing);
  });
}

void _onAction(MyPageDetailAction action) {}

void _onShare(CommunityPost post, BuildContext context) {}

Future<void> _onRefresh() async {}

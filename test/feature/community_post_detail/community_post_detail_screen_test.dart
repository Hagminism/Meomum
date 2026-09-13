import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_action.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_screen.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_state.dart';

void main() {
  final post = CommunityPost(
    id: 'post-id',
    authorId: 'account-id',
    upperRegion: '경상북도',
    lowerRegion: '포항시',
    nickname: '머뭄이',
    createdAt: DateTime(2026),
    category: CommunityCategory.free,
    title: '게시글 제목',
    content: '게시글 내용',
  );

  Widget buildScreen({required bool isOwner, bool isDeleting = false}) {
    return MaterialApp(
      home: CommunityPostDetailScreen(
        state: CommunityPostDetailState(
          post: post,
          isOwner: isOwner,
          isDeleting: isDeleting,
        ),
        onAction: (CommunityPostDetailAction action) {},
        onShare: (BuildContext context) {},
      ),
    );
  }

  testWidgets('작성자에게만 삭제 메뉴를 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(buildScreen(isOwner: true));
    await tester.tap(find.byType(PopupMenuButton<Object>));
    await tester.pumpAndSettle();

    expect(find.text('글 삭제'), findsOneWidget);
  });

  testWidgets('작성자가 아니면 삭제 메뉴를 표시하지 않는다', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen(isOwner: false));
    await tester.tap(find.byType(PopupMenuButton<Object>));
    await tester.pumpAndSettle();

    expect(find.text('글 삭제'), findsNothing);
    expect(find.text('신고하기'), findsOneWidget);
  });

  testWidgets('삭제 중에는 메뉴와 댓글 입력을 숨기고 진행 상태를 표시한다', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen(isOwner: true, isDeleting: true));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(PopupMenuButton<Object>), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });
}

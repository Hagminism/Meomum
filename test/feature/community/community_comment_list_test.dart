import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/feature/community/domain/model/community_comment.dart';
import 'package:meomum/feature/community/presentation/component/comment/community_comment_list.dart';

void main() {
  final comment = CommunityComment(
    id: 'comment-1',
    postId: 'post-1',
    authorId: 'author-1',
    nickname: '머뭄이',
    content: '수정할 댓글',
    createdAt: DateTime(2026, 9, 17),
  );

  testWidgets('댓글 수정 저장 중에는 입력과 두 액션을 비활성화한다', (
    WidgetTester tester,
  ) async {
    var cancelCount = 0;
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommunityCommentList(
            comments: [comment],
            postAuthorId: 'author-2',
            currentUserId: 'author-1',
            focusCommentId: null,
            replyParentId: null,
            editingCommentId: comment.id,
            editingContent: comment.content,
            isEditingSubmitting: true,
            onReply: (String commentId) {},
            onLike: (String commentId) {},
            onEdit: (String commentId) {},
            onDelete: (String commentId) {},
            onReport: (String commentId) {},
            onEditChanged: (String content) {},
            onEditSubmit: () {
              submitCount++;
            },
            onEditCancel: () {
              cancelCount++;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('comment-edit-취소')));
    await tester.tap(find.byKey(const ValueKey('comment-edit-저장')));

    expect(cancelCount, 0);
    expect(submitCount, 0);
  });
}

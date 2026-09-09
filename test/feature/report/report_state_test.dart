import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/report/presentation/screen/report_state.dart';

void main() {
  final post = CommunityPost(
    id: 'post-id',
    authorId: 'author-id',
    upperRegion: '경상북도',
    lowerRegion: '포항시',
    nickname: '머뭄이',
    createdAt: DateTime(2026),
    category: CommunityCategory.free,
    title: '게시글 제목',
    content: '게시글 내용',
  );

  test('제목과 본문이 비어 있으면 신고할 수 없다', () {
    final state = ReportState(post: post);

    expect(state.isSubmitEnabled, isFalse);
  });

  test('제목과 본문이 유효하면 신고할 수 있다', () {
    final state = ReportState(
      post: post,
      title: '신고 제목',
      content: '신고 내용',
    );

    expect(state.isSubmitEnabled, isTrue);
  });

  test('제출 중에는 신고 버튼을 다시 누를 수 없다', () {
    final state = ReportState(
      post: post,
      title: '신고 제목',
      content: '신고 내용',
      isSubmitting: true,
    );

    expect(state.isSubmitEnabled, isFalse);
  });
}

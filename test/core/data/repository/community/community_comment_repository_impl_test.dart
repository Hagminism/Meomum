import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/core/data/data_source/community/community_comment_data_source.dart';
import 'package:meomum/core/data/dto/community/community_comment_dto.dart';
import 'package:meomum/core/data/repository/community/community_comment_repository_impl.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/model/user/user.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';
import 'package:meomum/core/domain/repository/community/community_comment_repository.dart';
import 'package:meomum/core/domain/repository/storage_cleanup/storage_cleanup_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_comment.dart';

void main() {
  test('내 댓글 조회에서 본댓글이 없는 대댓글도 보존한다', () async {
    final dataSource = _FakeCommunityCommentDataSource(
      myComments: [
        CommunityCommentDto(
          id: 'reply-id',
          postId: 'post-id',
          parentId: 'root-id',
          authorId: 'account-id',
          content: '내가 쓴 대댓글',
          createdAt: DateTime.utc(2026, 1, 2).toIso8601String(),
        ),
      ],
    );
    final repository = _createRepository(dataSource: dataSource);

    final result = await repository.getMyComments();

    expect(result, isA<Success<List<CommunityComment>>>());
    final comments = (result as Success<List<CommunityComment>>).data;
    expect(comments, hasLength(1));
    expect(comments.single.id, 'reply-id');
    expect(comments.single.parentId, 'root-id');
    expect(dataSource.requestedAccountId, 'account-id');
  });
}

CommunityCommentRepository _createRepository({
  required _FakeCommunityCommentDataSource dataSource,
}) {
  return CommunityCommentRepositoryImpl(
    dataSource: dataSource,
    authRepository: _FakeAuthRepository(),
    storageCleanupRepository: _FakeStorageCleanupRepository(),
  );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  User? get currentUser => User(
    id: 'account-id',
    nickname: '머뭄이',
    authProvider: AuthProvider.google,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCommunityCommentDataSource implements CommunityCommentDataSource {
  _FakeCommunityCommentDataSource({this.myComments = const []});

  final List<CommunityCommentDto> myComments;
  String? requestedAccountId;

  @override
  Future<Result<List<CommunityCommentDto>>> getMyComments({
    required String accountId,
    int limit = 20,
    DateTime? cursor,
  }) async {
    requestedAccountId = accountId;
    return Result.success(myComments);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStorageCleanupRepository implements StorageCleanupRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

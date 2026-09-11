import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/community_post_image.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community_edit_post/presentation/screen/community_edit_post_state.dart';
import 'package:meomum/feature/community_post_form/presentation/model/community_post_form_media.dart';

void main() {
  const region = CommunityRegion(
    upperRegion: '경상북도',
    lowerRegion: '포항시',
  );
  const image = CommunityPostImage(
    storagePath: 'accounts/account-id/post.jpg',
    publicUrl: 'https://example.com/post.jpg',
    sortOrder: 0,
  );
  final post = CommunityPost(
    id: 'post-id',
    authorId: 'account-id',
    upperRegion: region.upperRegion,
    lowerRegion: region.lowerRegion,
    nickname: '머뭄이',
    createdAt: DateTime(2026),
    category: CommunityCategory.free,
    title: '게시글 제목',
    content: '게시글 내용',
    imageUrls: [image.publicUrl],
    images: [image],
  );

  CommunityEditPostState createState({
    String title = '게시글 제목',
    String content = '게시글 내용',
    List<CommunityPostFormMedia> mediaItems = const [
      CommunityPostFormMedia.remote(image: image),
    ],
  }) {
    return CommunityEditPostState(
      postId: post.id,
      selectedRegion: region,
      originalPost: post,
      title: title,
      content: content,
      mediaItems: mediaItems,
      isInitializing: false,
    );
  }

  test('원본과 동일하면 변경 사항이 없다', () {
    final state = createState();

    expect(state.hasChanges, isFalse);
    expect(state.isUploadEnabled, isFalse);
  });

  test('제목의 실제 내용이 변경되면 수정할 수 있다', () {
    final state = createState(title: '변경된 제목');

    expect(state.hasChanges, isTrue);
    expect(state.isUploadEnabled, isTrue);
  });

  test('저장 값에 반영되지 않는 공백만 변경하면 변경으로 보지 않는다', () {
    final state = createState(
      title: '  게시글 제목  ',
      content: '\n게시글 내용\n',
    );

    expect(state.hasChanges, isFalse);
  });

  test('기존 이미지를 삭제하면 변경 사항으로 판단한다', () {
    final state = createState(mediaItems: const []);

    expect(state.hasChanges, isTrue);
    expect(state.isUploadEnabled, isTrue);
  });

  test('새 로컬 이미지를 추가하면 변경 사항으로 판단한다', () {
    final state = createState(
      mediaItems: [
        const CommunityPostFormMedia.remote(image: image),
        CommunityPostFormMedia.local(file: XFile('/tmp/new.jpg')),
      ],
    );

    expect(state.hasChanges, isTrue);
  });
}

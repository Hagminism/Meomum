import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_state.dart';

void main() {
  const region = CommunityRegion(upperRegion: '경북', lowerRegion: '포항시');

  test('일자리 글은 마감일 또는 상시 모집이 있어야 업로드할 수 있다', () {
    final state = CommunityPostFormState(
      selectedRegion: region,
      category: CommunityCategory.job,
      title: '구인합니다',
      content: '본문입니다.',
      wageType: '건당',
      wageAmount: '50000',
    );

    expect(state.isUploadEnabled, isFalse);
    expect(state.uploadValidationMessage, contains('모집 마감일'));
    expect(
      state.copyWith(isAlwaysRecruiting: true).isUploadEnabled,
      isTrue,
    );
  });

  test('협의 급여는 금액을 비워야 업로드할 수 있다', () {
    final state = CommunityPostFormState(
      selectedRegion: region,
      category: CommunityCategory.job,
      title: '구인합니다',
      content: '본문입니다.',
      wageType: '협의',
      wageAmount: '10000',
      isAlwaysRecruiting: true,
    );

    expect(state.isUploadEnabled, isFalse);
    expect(state.uploadValidationMessage, contains('금액을 입력하지 않습니다'));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/on_boarding/feature/select_region/presentation/screen/select_region_state.dart';

void main() {
  test('지역을 선택하기 전에는 제출할 수 없다', () {
    const state = SelectRegionState();

    expect(state.isValid, isFalse);
  });

  test('지역을 선택하면 제출할 수 있다', () {
    const state = SelectRegionState(
      selectedRegion: CommunityRegion(
        upperRegion: '경상북도',
        lowerRegion: '포항시',
      ),
    );

    expect(state.isValid, isTrue);
  });
}

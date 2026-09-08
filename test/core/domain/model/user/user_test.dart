import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/core/domain/model/user/user.dart';

void main() {
  group('User 지역 선택 상태', () {
    test('상위 지역과 하위 지역이 모두 있으면 선택 완료로 판단한다', () {
      const user = User(
        id: 'account-id',
        nickname: '머뭄이',
        upperRegion: '경상북도',
        lowerRegion: '포항시',
      );

      expect(user.hasSelectedRegion, isTrue);
      expect(user.hasPartialRegion, isFalse);
    });

    test('지역이 일부만 있으면 잘못된 부분 선택으로 판단한다', () {
      const user = User(
        id: 'account-id',
        nickname: '머뭄이',
        upperRegion: '경상북도',
      );

      expect(user.hasSelectedRegion, isFalse);
      expect(user.hasPartialRegion, isTrue);
    });
  });
}

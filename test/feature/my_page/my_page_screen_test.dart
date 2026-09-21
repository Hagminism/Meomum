import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/feature/my_page/domain/model/current_stay.dart';
import 'package:meomum/feature/my_page/domain/model/my_page_promotion.dart';
import 'package:meomum/feature/my_page/domain/model/stay_history_item.dart';
import 'package:meomum/feature/my_page/presentation/component/my_page_promotion_carousel.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_screen.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_state.dart';

void main() {
  testWidgets('마이페이지는 홍보 캐러셀을 표시하고 체류 정보는 숨긴다', (tester) async {
    final actions = <MyPageAction>[];

    await tester.pumpWidget(
      MaterialApp(
        home: MyPageScreen(
          state: MyPageState(
            currentStay: const CurrentStay(
              location: '경상북도 포항시',
              dateRange: '6월 30일 - 7월 20일',
              jobType: '일자리',
              accommodation: '숙소',
            ),
            promotions: const [
              MyPagePromotion(
                id: 'community',
                eyebrow: '지역 커뮤니티',
                title: '낯선 동네에서도\n함께 시작해요',
                subtitle: '동네 이야기와 유용한 정보를 만나보세요.',
                imageAssetPath: 'assets/images/my_page_carousel/community.png',
              ),
              MyPagePromotion(
                id: 'stay-and-work',
                eyebrow: '머무는 생활',
                title: '머물 곳과 일할 곳을\n한 번에 찾아보세요',
                subtitle: '숙소와 일자리 정보를 한곳에서 확인해요.',
                imageAssetPath:
                    'assets/images/my_page_carousel/stay-and-work.png',
              ),
            ],
            stayHistories: [
              const StayHistoryItem(
                id: 'stay-1',
                location: '전라남도 순천시',
                dateRange: '2026년 6월 30일 - 2026년 7월 20일',
              ),
            ],
          ),
          onAction: actions.add,
          onRefresh: _onRefresh,
        ),
      ),
    );

    expect(find.byType(MyPagePromotionCarousel), findsOneWidget);
    expect(find.text('지역 커뮤니티'), findsOneWidget);
    expect(find.text('지금 머무는 중'), findsNothing);
    expect(find.text('머문 기록'), findsNothing);

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('머무는 생활'), findsOneWidget);
    expect(actions, contains(const MyPageAction.changePromotionIndex(1)));
  });
}

Future<void> _onRefresh() async {}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community/domain/model/enum/community_job_source.dart';
import 'package:meomum/feature/community/domain/model/tour_api_job_posting.dart';
import 'package:meomum/feature/community/presentation/component/job/community_job_board.dart';
import 'package:meomum/feature/community/presentation/component/job/community_job_source_filter_bar.dart';

void main() {
  void noopShare(CommunityPost post, BuildContext context) {}

  testWidgets('필터 바에서 사용자 구인글과 관광인 채용정보를 전환한다', (
    WidgetTester tester,
  ) async {
    final userPost = CommunityPost(
      id: 'user-job-1',
      authorId: 'author-1',
      upperRegion: '경북',
      lowerRegion: '포항시',
      nickname: '이웃',
      createdAt: DateTime.now(),
      category: CommunityCategory.job,
      title: '카페 주말 알바 구합니다',
      content: '함께 일할 분을 찾습니다.',
      jobWageType: '시급',
      jobWageAmount: 11000,
      jobWorkingTime: '토·일 10:00~16:00',
      jobRecruitmentDeadline: DateTime.now().add(const Duration(days: 3)),
    );
    final apiPosting = TourApiJobPosting(
      empmnInfoNo: 'api-job-1',
      upperRegion: '경북',
      lowerRegion: '포항시',
      title: '관광호텔 프런트 채용',
      companyName: '관광호텔',
      workplace: '포항시 북구',
      salary: '월 250만원',
      employmentType: '정규직',
      isAlwaysRecruiting: true,
    );

    var selectedSource = CommunityJobSource.userPosts;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  CommunityJobSourceFilterBar(
                    selectedSource: selectedSource,
                    onSourcePressed: (CommunityJobSource source) {
                      setState(() {
                        selectedSource = source;
                      });
                    },
                  ),
                  Expanded(
                    child: CommunityJobBoard(
                      userPosts: [userPost],
                      apiPostings: [apiPosting],
                      isApiLoading: false,
                      apiErrorMessage: null,
                      selectedSource: selectedSource,
                      bottomPadding: 24,
                      onAction: (_) {},
                      onShare: noopShare,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('우리동네 구인글'), findsNWidgets(2));
    expect(find.text('관광인 채용'), findsOneWidget);
    expect(find.text('사용자 작성'), findsOneWidget);
    expect(find.text('관광인 제공'), findsNothing);
    expect(find.text('카페 주말 알바 구합니다'), findsOneWidget);
    expect(find.text('관광호텔 프런트 채용'), findsNothing);

    await tester.tap(find.text('관광인 채용').first);
    await tester.pump();

    expect(find.text('우리동네 구인글'), findsOneWidget);
    expect(find.text('관광인 채용'), findsNWidgets(2));
    expect(find.text('사용자 작성'), findsNothing);
    expect(find.text('관광인 제공'), findsNothing);
    expect(find.text('카페 주말 알바 구합니다'), findsNothing);
    expect(find.text('관광호텔 프런트 채용'), findsOneWidget);
    expect(find.text('상시 모집'), findsOneWidget);
  });

  testWidgets('구인글이 없으면 카드 없이 화면 중앙에 빈 상태를 표시한다', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommunityJobBoard(
            userPosts: const [],
            apiPostings: const [],
            isApiLoading: false,
            apiErrorMessage: null,
            selectedSource: CommunityJobSource.userPosts,
            bottomPadding: 24,
            onAction: (_) {},
            onShare: noopShare,
          ),
        ),
      ),
    );

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('아직 우리동네 구인글이 없어요.'),
        matching: find.byType(Center),
      ),
      findsOneWidget,
    );
    expect(find.byType(DecoratedBox), findsNothing);
    expect(find.text('아직 우리동네 구인글이 없어요.'), findsOneWidget);
  });

  testWidgets('마감된 구인글은 목록에 남고 마감 상태를 표시한다', (
    WidgetTester tester,
  ) async {
    final closedPosting = TourApiJobPosting(
      empmnInfoNo: 'api-job-closed',
      upperRegion: '경북',
      lowerRegion: '포항시',
      title: '마감된 채용정보',
      recruitmentDeadline: DateTime.now().subtract(const Duration(days: 1)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommunityJobBoard(
            userPosts: const [],
            apiPostings: [closedPosting],
            isApiLoading: false,
            apiErrorMessage: null,
            selectedSource: CommunityJobSource.tourApi,
            bottomPadding: 24,
            onAction: (_) {},
            onShare: noopShare,
          ),
        ),
      ),
    );

    expect(find.text('마감된 채용정보'), findsOneWidget);
    expect(find.text('마감'), findsOneWidget);
  });
}

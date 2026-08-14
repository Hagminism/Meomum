import 'package:meomum/feature/community/domain/model/community_category.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';

class CommunityMockData {
  static const CommunityRegion pohang = CommunityRegion(
    upperRegion: '경상북도',
    lowerRegion: '포항시',
    neighborhoods: ['죽도동', '양덕동', '효자동', '오천읍'],
  );

  static const CommunityRegion gyeongju = CommunityRegion(
    upperRegion: '경상북도',
    lowerRegion: '경주시',
    neighborhoods: ['황남동', '황성동', '동천동', '감포읍'],
  );

  static const CommunityRegion yeongdeungpo = CommunityRegion(
    upperRegion: '서울특별시',
    lowerRegion: '영등포구',
    neighborhoods: ['문래동', '여의동', '당산동', '신길동'],
  );

  static const CommunityRegion mapo = CommunityRegion(
    upperRegion: '서울특별시',
    lowerRegion: '마포구',
    neighborhoods: ['서교동', '연남동', '망원동', '합정동'],
  );

  static const CommunityRegion haeundae = CommunityRegion(
    upperRegion: '부산광역시',
    lowerRegion: '해운대구',
    neighborhoods: ['우동', '중동', '좌동', '송정동'],
  );

  static const List<CommunityRegion> regions = [
    pohang,
    gyeongju,
    yeongdeungpo,
    mapo,
    haeundae,
  ];

  static const List<CommunityPost> posts = [
    CommunityPost(
      id: 'post-pohang-free-1',
      region: pohang,
      nickname: '포항한달러',
      neighborhood: '죽도동',
      timeLabel: '1분 전',
      category: CommunityCategory.free,
      title: '바다 바람 맞으며 패러글라이딩한 날',
      content: '처음에는 조금 무서웠는데 막상 올라가니 포항 바다가 한눈에 보여서 정말 좋았어요.',
      likeCount: 20,
      commentCount: 4,
      isVerified: true,
      imageUrls: [
        'https://images.unsplash.com/photo-1521389508051-d7ffb5dc8a40?w=900&q=85',
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=900&q=85',
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=900&q=85',
      ],
      place: CommunityPlace(
        name: '포항중앙시장',
        latitude: 36.0389,
        longitude: 129.3658,
      ),
    ),
    CommunityPost(
      id: 'post-pohang-free-2',
      region: pohang,
      nickname: '머뭄생활자',
      neighborhood: '효자동',
      timeLabel: '12분 전',
      category: CommunityCategory.free,
      title: '포항에서 한 달 살기 시작했어요',
      content: '사진 없이도 동네 소식을 편하게 나눌 수 있는 공간이 생겨 반갑습니다.',
      likeCount: 8,
      commentCount: 2,
    ),
    CommunityPost(
      id: 'post-pohang-life-1',
      region: pohang,
      nickname: '양덕이웃',
      neighborhood: '양덕동',
      timeLabel: '25분 전',
      category: CommunityCategory.life,
      title: '종량제 봉투는 여기서 살 수 있어요',
      content: '주민센터 옆 편의점에서 크기별로 판매하고 있으니 참고하세요.',
      likeCount: 11,
      commentCount: 3,
    ),
    CommunityPost(
      id: 'post-pohang-restaurant-1',
      region: pohang,
      nickname: '포항미식가',
      neighborhood: '죽도동',
      timeLabel: '40분 전',
      category: CommunityCategory.restaurant,
      title: '시장 안 물회집 다녀왔습니다',
      content: '회가 신선하고 양도 넉넉해서 다음에도 다시 방문하려고 해요.',
      likeCount: 31,
      commentCount: 9,
      imageUrls: [
        'https://images.unsplash.com/photo-1547592180-85f173990554?w=900&q=85',
      ],
      place: CommunityPlace(
        name: '죽도시장',
        latitude: 36.0373,
        longitude: 129.365,
      ),
    ),
    CommunityPost(
      id: 'post-pohang-tourism-1',
      region: pohang,
      nickname: '여행기록가',
      neighborhood: '오천읍',
      timeLabel: '1시간 전',
      category: CommunityCategory.tourism,
      title: '호미곶 일출은 평일 아침을 추천해요',
      content: '주말보다 한적해서 천천히 산책하고 사진 찍기 좋았습니다.',
      likeCount: 44,
      commentCount: 7,
      imageUrls: [
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=900&q=85',
      ],
    ),
    CommunityPost(
      id: 'post-pohang-accommodation-1',
      region: pohang,
      nickname: '숙소탐방대',
      neighborhood: '효자동',
      timeLabel: '2시간 전',
      category: CommunityCategory.accommodation,
      title: '한 달 머물기 좋은 조용한 숙소 후기',
      content: '공용 업무 공간이 있고 주변에 산책로가 있어 장기 체류하기 편했어요.',
      likeCount: 17,
      commentCount: 5,
    ),
    CommunityPost(
      id: 'post-pohang-job-1',
      region: pohang,
      nickname: '동네소식통',
      neighborhood: '양덕동',
      timeLabel: '3시간 전',
      category: CommunityCategory.job,
      title: '주말 카페 아르바이트 구해요',
      content: '토요일과 일요일 오전 시간대에 함께 일할 분을 찾고 있습니다.',
      likeCount: 6,
      commentCount: 1,
    ),
    CommunityPost(
      id: 'post-seoul-free-1',
      region: yeongdeungpo,
      nickname: '문래산책자',
      neighborhood: '문래동',
      timeLabel: '5분 전',
      category: CommunityCategory.free,
      title: '문래창작촌 저녁 산책 코스',
      content: '골목마다 작은 전시 공간이 있어 천천히 둘러보기 좋았습니다.',
      likeCount: 14,
      commentCount: 6,
      imageUrls: [
        'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=900&q=85',
      ],
    ),
  ];

  const CommunityMockData._();
}

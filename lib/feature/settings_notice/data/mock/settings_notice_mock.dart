import 'package:meomum/feature/settings_notice/domain/model/settings_notice.dart';

const List<SettingsNotice> settingsNoticeMockData = [
  SettingsNotice(
    id: 'launch',
    date: '26/09/14',
    title: '머뭄의 시작을 축하해요 🎉 서비스 런칭 안내',
    content:
        '머뭄이 여행자와 지역을 잇는 첫 여정을 시작합니다.\n\n'
        '머무는 동안 발견한 동네의 이야기와 따뜻한 정보를 편하게 나눠보세요.\n\n'
        '앞으로 더 나은 여행 경험을 만들기 위해 꾸준히 업데이트하겠습니다.',
  ),
  SettingsNotice(
    id: 'community-guide',
    date: '26/09/10',
    title: '동네 이야기를 나누는 커뮤니티 이용 안내',
    content:
        '지역을 선택하고, 머물렀던 장소와 일상의 이야기를 자유롭게 남겨보세요.\n\n'
        '다른 여행자를 배려하는 따뜻한 말투와 정확한 정보를 함께 지켜주세요.',
  ),
  SettingsNotice(
    id: 'profile-guide',
    date: '26/09/05',
    title: '나에게 맞는 머뭄을 찾는 프로필 설정 안내',
    content:
        '프로필과 관심 지역을 설정하면 머뭄에서 더 가까운 동네 소식을 만날 수 있습니다.\n\n'
        '마이페이지에서 언제든 프로필 정보를 수정할 수 있어요.',
  ),
];

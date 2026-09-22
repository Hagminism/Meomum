enum CommunityJobSource {
  userPosts(label: '우리동네 구인글'),
  tourApi(label: '관광인 채용');

  final String label;

  const CommunityJobSource({required this.label});
}

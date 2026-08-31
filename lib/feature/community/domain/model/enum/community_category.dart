enum CommunityCategory {
  free(
    label: '자유',
    assetPath: 'assets/icons/category/general_discussion.png',
  ),
  life(
    label: '생활',
    assetPath: 'assets/icons/category/life_style.png',
  ),
  restaurant(
    label: '맛집',
    assetPath: 'assets/icons/category/restaurant.png',
  ),
  tourism(
    label: '관광',
    assetPath: 'assets/icons/category/sight_seeing.png',
  ),
  accommodation(
    label: '숙소',
    assetPath: 'assets/icons/category/accommodation.png',
  ),
  job(
    label: '일자리',
    assetPath: 'assets/icons/category/job.png',
  );

  final String label;
  final String assetPath;

  const CommunityCategory({
    required this.label,
    required this.assetPath,
  });
}

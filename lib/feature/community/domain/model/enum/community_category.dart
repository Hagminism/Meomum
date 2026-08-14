enum CommunityCategory {
  free(label: '자유'),
  life(label: '생활'),
  restaurant(label: '맛집'),
  tourism(label: '관광'),
  accommodation(label: '숙소'),
  job(label: '일자리');

  final String label;

  const CommunityCategory({
    required this.label,
  });
}

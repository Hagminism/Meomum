enum MapCategory {
  restaurant(
    label: '음식점',
    contentTypeIds: <String>{'39'},
  ),
  convenienceStore(
    label: '마트∙편의점',
    contentTypeIds: <String>{'38'},
  ),
  space(
    label: '공간',
    contentTypeIds: <String>{'14', '28'},
  ),
  accommodation(
    label: '숙박',
    contentTypeIds: <String>{'32'},
  ),
  tourism(
    label: '관광',
    contentTypeIds: <String>{'12', '15', '25'},
  );

  final String label;
  final Set<String> contentTypeIds;

  const MapCategory({
    required this.label,
    required this.contentTypeIds,
  });

  /// contentTypeId가 contentTypeIds에 포함되어 있는지 확인
  bool containsContentTypeId(String? contentTypeId) {
    return contentTypeId != null && contentTypeIds.contains(contentTypeId);
  }
}

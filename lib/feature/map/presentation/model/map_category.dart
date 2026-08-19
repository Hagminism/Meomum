enum MapCategory {
  restaurant(
    label: '음식점',
    indsLclsCodes: <String>{'I2'},
  ),
  convenienceStore(
    label: '마트∙편의점',
    indsLclsCodes: <String>{'G2'},
  ),
  space(
    label: '공간',
    indsLclsCodes: <String>{'R1'},
  ),
  accommodation(
    label: '숙박',
    indsLclsCodes: <String>{'I1'},
  );

  final String label;
  final Set<String> indsLclsCodes;

  const MapCategory({
    required this.label,
    required this.indsLclsCodes,
  });

  /// 업종 대분류 코드가 해당 카테고리에 포함되어 있는지 확인
  bool containsIndsLclsCd(String? indsLclsCd) {
    return indsLclsCd != null && indsLclsCodes.contains(indsLclsCd);
  }
}

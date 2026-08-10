enum AuthProvider {
  google,
  naver,
  kakao;

  String toDisplayName() => switch (this) {
    AuthProvider.google => '구글',
    AuthProvider.naver => '네이버',
    AuthProvider.kakao => '카카오',
  };
}

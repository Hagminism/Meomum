import 'dart:convert';

import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';

class Routes {
  static const String splash = '/splash';
  static const String signIn = '/sign-in';
  static const String onBoarding = '/on-boarding';
  static const String onBoardingCreateProfile = 'create-profile';
  static const String onBoardingSelectRegion = 'select-region';

  static const String home = '/home';
  static const String community = '/community';
  static const String communityCategoryQuery = 'category';
  static const String postDetail = 'post-detail/:postId';
  static const String postId = 'postId';
  static const String postEdit = 'edit-post';
  static const String communityWrite = 'write';
  static const String communityLocationSearch = 'location-search';
  static const String report = 'report';
  static const String map = '/map';
  static const String mapSearch = 'map-search';
  static const String storeDetail = 'store-detail';
  static const String storeDetailQuery = 'store';
  static const String jobs = '/jobs';
  static const String myPage = '/my-page';
  static const String myPageSettings = 'settings';
  static const String myPageSettingsNotices = 'notices';
  static const String myPageFeed = 'feed';
  static const String myPageFeedEditProfile = 'edit-profile';
  static const String myPageFeedEditRegion = 'edit-region';
  static const String myPageFeedPostDetail = 'post-detail/:postId';

  static String storeDetailLocation(CommercialStore store) {
    return Uri(
      path: '$map/$storeDetail',
      queryParameters: <String, String>{
        storeDetailQuery: jsonEncode(store.toJson()),
      },
    ).toString();
  }

  static CommercialStore? storeFromDetailQuery(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map) return null;

      return CommercialStore.fromJson(Map<String, dynamic>.from(decoded));
    } on Object {
      return null;
    }
  }
}

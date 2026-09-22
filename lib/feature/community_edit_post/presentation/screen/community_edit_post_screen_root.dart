import 'package:flutter/material.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_screen_root.dart';

class CommunityEditPostScreenRoot extends StatelessWidget {
  final String postId;

  const CommunityEditPostScreenRoot({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return CommunityPostFormScreenRoot(postId: postId);
  }
}

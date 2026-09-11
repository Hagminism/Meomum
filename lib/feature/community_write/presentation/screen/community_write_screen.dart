import 'package:flutter/material.dart';
import 'package:meomum/feature/community_post_form/presentation/model/community_post_form_media.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_action.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_screen.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_state.dart';

class CommunityWriteScreen extends StatelessWidget {
  final CommunityWriteState state;
  final void Function(CommunityPostFormAction) onAction;

  const CommunityWriteScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return CommunityPostFormScreen(
      appBarTitle: '새 글 작성',
      uploadButtonLabel: '업로드',
      selectedRegion: state.selectedRegion,
      category: state.category,
      mediaItems: state.mediaFiles
          .map(
            (file) => CommunityPostFormMedia.local(file: file),
          )
          .toList(growable: false),
      selectedPlace: state.selectedPlace,
      title: state.title,
      content: state.content,
      isUploadEnabled: state.isUploadEnabled,
      isLoading: state.isLoading,
      onAction: onAction,
    );
  }
}

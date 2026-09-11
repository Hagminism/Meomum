import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_action.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_screen.dart';
import 'package:meomum/feature/community_edit_post/presentation/screen/community_edit_post_state.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityEditPostScreen extends StatelessWidget {
  final CommunityEditPostState state;
  final void Function(CommunityPostFormAction) onAction;

  const CommunityEditPostScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isInitializing) {
      return _buildStatusScreen(
        context,
        const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.errorMessage != null) {
      return _buildStatusScreen(
        context,
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
          ),
        ),
      );
    }

    return CommunityPostFormScreen(
      appBarTitle: '글 수정',
      uploadButtonLabel: '수정하기',
      selectedRegion: state.selectedRegion,
      category: state.category,
      mediaItems: state.mediaItems,
      selectedPlace: state.selectedPlace,
      title: state.title,
      content: state.content,
      isUploadEnabled: state.isUploadEnabled,
      isLoading: state.isLoading,
      onAction: onAction,
    );
  }

  Widget _buildStatusScreen(BuildContext context, Widget body) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          onAction(const CommunityPostFormAction.tapBack());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.writeBackground,
        appBar: CustomAppBar(
          title: '글 수정',
          titleColor: const Color(0xFF646465),
          showCloseButton: true,
          onClosePressed: () => onAction(
            const CommunityPostFormAction.tapBack(),
          ),
        ),
        body: body,
      ),
    );
  }
}

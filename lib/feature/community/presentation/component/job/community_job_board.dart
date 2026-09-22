import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/enum/community_job_source.dart';
import 'package:meomum/feature/community/domain/model/tour_api_job_posting.dart';
import 'package:meomum/feature/community/presentation/component/job/community_job_api_error.dart';
import 'package:meomum/feature/community/presentation/component/job/community_job_empty_state.dart';
import 'package:meomum/feature/community/presentation/component/job/community_job_section_header.dart';
import 'package:meomum/feature/community/presentation/component/job/community_tour_job_card.dart';
import 'package:meomum/feature/community/presentation/component/job/community_user_job_card.dart';
import 'package:meomum/feature/community/presentation/screen/community_action.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityJobBoard extends StatelessWidget {
  final List<CommunityPost> userPosts;
  final List<TourApiJobPosting> apiPostings;
  final bool isApiLoading;
  final String? apiErrorMessage;
  final CommunityJobSource selectedSource;
  final double bottomPadding;
  final void Function(CommunityAction action) onAction;
  final void Function(CommunityPost post, BuildContext context) onShare;

  const CommunityJobBoard({
    super.key,
    required this.userPosts,
    required this.apiPostings,
    required this.isApiLoading,
    required this.apiErrorMessage,
    required this.selectedSource,
    required this.bottomPadding,
    required this.onAction,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final hasUserPosts = userPosts.isNotEmpty;
    final hasApiPosts = apiPostings.isNotEmpty;
    final showUserPosts = selectedSource == CommunityJobSource.userPosts;
    final isEmptyState = showUserPosts
        ? !hasUserPosts
        : !isApiLoading && apiErrorMessage == null && !hasApiPosts;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      onRefresh: () async => onAction(const CommunityAction.refresh()),
      child: isEmptyState
          ? _buildEmptyState(
              showUserPosts: showUserPosts,
              bottomPadding: bottomPadding,
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPadding),
              children: [
                if (showUserPosts) ...[
                  const CommunityJobSectionHeader(title: '우리동네 구인글'),
                  if (hasUserPosts)
                    ...userPosts.map(
                      (CommunityPost post) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CommunityUserJobCard(
                          post: post,
                          onTap: () =>
                              onAction(CommunityAction.tapPost(post.id)),
                          onLike: () =>
                              onAction(CommunityAction.toggleLike(post.id)),
                          onComment: () =>
                              onAction(CommunityAction.tapComment(post.id)),
                          onShare: () => onShare(post, context),
                        ),
                      ),
                    ),
                ] else ...[
                  const CommunityJobSectionHeader(
                    title: '관광인 채용',
                    showSourceNotice: true,
                  ),
                  if (isApiLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  if (!isApiLoading && apiErrorMessage != null && !hasApiPosts)
                    CommunityJobApiError(message: apiErrorMessage!),
                  if (!isApiLoading && hasApiPosts)
                    ...apiPostings.map(
                      (TourApiJobPosting posting) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CommunityTourJobCard(
                          posting: posting,
                          onTap: () => onAction(
                            CommunityAction.tapTourApiJob(posting.empmnInfoNo),
                          ),
                        ),
                      ),
                    ),
                  if (apiErrorMessage != null && hasApiPosts)
                    const Padding(
                      padding: EdgeInsets.only(top: 2, bottom: 8),
                      child: Text(
                        '관광인 채용정보가 일부 최신 상태가 아닐 수 있어요. 아래로 당겨 새로고침해주세요.',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: AppColors.communityMetaText,
                        ),
                      ),
                    ),
                ],
              ],
            ),
    );
  }

  Widget _buildEmptyState({
    required bool showUserPosts,
    required double bottomPadding,
  }) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          sliver: SliverToBoxAdapter(
            child: CommunityJobSectionHeader(
              title: showUserPosts ? '우리동네 구인글' : '관광인 채용',
              showSourceNotice: !showUserPosts,
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
            child: Center(
              child: CommunityJobEmptyState(
                icon: showUserPosts
                    ? Icons.person_search_outlined
                    : Icons.travel_explore_outlined,
                message: showUserPosts
                    ? '아직 우리동네 구인글이 없어요.'
                    : '현재 표시할 관광인 채용정보가 없어요.',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

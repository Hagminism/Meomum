import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/tour_api_job_posting.dart';
import 'package:meomum/feature/community/presentation/screen/community_action.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityJobBoard extends StatelessWidget {
  final List<CommunityPost> userPosts;
  final List<TourApiJobPosting> apiPostings;
  final bool isApiLoading;
  final String? apiErrorMessage;
  final double bottomPadding;
  final void Function(CommunityAction action) onAction;
  final void Function(CommunityPost post, BuildContext context) onShare;

  const CommunityJobBoard({
    super.key,
    required this.userPosts,
    required this.apiPostings,
    required this.isApiLoading,
    required this.apiErrorMessage,
    required this.bottomPadding,
    required this.onAction,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final hasUserPosts = userPosts.isNotEmpty;
    final hasApiPosts = apiPostings.isNotEmpty;
    final hasContent = hasUserPosts || hasApiPosts || isApiLoading;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      onRefresh: () async => onAction(const CommunityAction.refresh()),
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPadding),
        children: [
          _CommunityJobSectionHeader(
            title: '우리동네 구인글',
            subtitle: hasUserPosts ? '이웃이 직접 올린 일자리예요.' : null,
          ),
          if (hasUserPosts)
            ...userPosts.map(
              (CommunityPost post) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CommunityUserJobCard(
                  post: post,
                  onTap: () => onAction(CommunityAction.tapPost(post.id)),
                  onLike: () => onAction(CommunityAction.toggleLike(post.id)),
                  onComment: () => onAction(
                    CommunityAction.tapComment(post.id),
                  ),
                  onShare: () => onShare(post, context),
                ),
              ),
            )
          else
            const _CommunityJobSectionEmpty(
              icon: Icons.person_search_outlined,
              message: '아직 우리동네 구인글이 없어요.',
            ),
          const SizedBox(height: 24),
          _CommunityJobSectionHeader(
            title: '관광인 채용',
            subtitle: '한국관광공사 관광인에서 제공하는 채용정보예요.',
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
            _CommunityJobApiError(message: apiErrorMessage!),
          if (!isApiLoading && hasApiPosts)
            ...apiPostings.map(
              (TourApiJobPosting posting) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CommunityTourJobCard(
                  posting: posting,
                  onTap: () => onAction(
                    CommunityAction.tapTourApiJob(posting.empmnInfoNo),
                  ),
                ),
              ),
            ),
          if (!isApiLoading && apiErrorMessage == null && !hasApiPosts)
            const _CommunityJobSectionEmpty(
              icon: Icons.travel_explore_outlined,
              message: '현재 표시할 관광인 채용정보가 없어요.',
            ),
          if (apiErrorMessage != null && hasApiPosts)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 8),
              child: Text(
                '관광인 채용정보가 일부 최신 상태가 아닐 수 있어요. 아래로 당겨 새로고침해주세요.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  color: AppColors.communityMetaText,
                ),
              ),
            ),
          if (!hasContent && apiErrorMessage == null)
            const _CommunityJobSectionEmpty(
              icon: Icons.work_outline_rounded,
              message: '아직 등록된 구인정보가 없어요.',
            ),
        ],
      ),
    );
  }
}

class _CommunityJobSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showSourceNotice;

  const _CommunityJobSectionHeader({
    required this.title,
    this.subtitle,
    this.showSourceNotice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.communityText,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: AppColors.communityMetaText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showSourceNotice)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: _CommunitySourceBadge(),
            ),
        ],
      ),
    );
  }
}

class _CommunitySourceBadge extends StatelessWidget {
  const _CommunitySourceBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.categoryHighlight,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.verified_rounded,
              size: 14,
              color: AppColors.uploadButton,
            ),
            SizedBox(width: 4),
            Text(
              '관광인 제공',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.uploadButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityUserJobCard extends StatelessWidget {
  final CommunityPost post;
  final void Function() onTap;
  final void Function() onLike;
  final void Function() onComment;
  final void Function() onShare;

  const _CommunityUserJobCard({
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = _isClosed;
    return Semantics(
      button: true,
      label: '사용자 작성 구인글 ${post.title}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _CommunityUserSourceLabel(),
                    const Spacer(),
                    if (isClosed) const _CommunityClosedBadge(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.communityText,
                  ),
                ),
                const SizedBox(height: 9),
                if (post.jobWageType != null || post.jobWorkingTime != null)
                  _CommunityJobMetaLine(
                    wage: _wageLabel,
                    workingTime: post.jobWorkingTime,
                  ),
                const SizedBox(height: 8),
                _CommunityDeadlineLine(
                  label: _deadlineLabel,
                  isClosed: isClosed,
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${post.nickname} · ${post.timeLabel}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: AppColors.communityMetaText,
                        ),
                      ),
                    ),
                    _CommunityActionIcon(
                      icon: post.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      label: '${post.likeCount}',
                      color: post.isLiked
                          ? AppColors.snackBarError
                          : AppColors.communityMetaText,
                      onTap: onLike,
                    ),
                    const SizedBox(width: 8),
                    _CommunityActionIcon(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: '${post.commentCount}',
                      onTap: onComment,
                    ),
                    const SizedBox(width: 8),
                    _CommunityActionIcon(
                      icon: Icons.ios_share_rounded,
                      onTap: onShare,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _isClosed =>
      !post.jobIsAlwaysRecruiting &&
      post.jobRecruitmentDeadline != null &&
      DateTime(
        post.jobRecruitmentDeadline!.year,
        post.jobRecruitmentDeadline!.month,
        post.jobRecruitmentDeadline!.day,
      ).isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );

  String? get _wageLabel {
    final type = post.jobWageType;
    if (type == null) return null;
    if (type == '협의') return '급여 협의';
    final amount = post.jobWageAmount;
    return amount == null ? type : '$type ${amount.toStringAsFixed(0)}원';
  }

  String get _deadlineLabel {
    if (post.jobIsAlwaysRecruiting) return '상시 모집';
    final date = post.jobRecruitmentDeadline;
    if (date == null) return '마감일 미정';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} 마감';
  }
}

class _CommunityTourJobCard extends StatelessWidget {
  final TourApiJobPosting posting;
  final void Function() onTap;

  const _CommunityTourJobCard({required this.posting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '한국관광공사 제공 채용정보 ${posting.title}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8F1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD9E7D2)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _CommunitySourceBadge(),
                    const Spacer(),
                    if (posting.isClosed) const _CommunityClosedBadge(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  posting.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.communityText,
                  ),
                ),
                if (posting.companyName != null) ...[
                  const SizedBox(height: 7),
                  Text(
                    posting.companyName!,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.uploadButton,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                _CommunityApiInfoLine(
                  workplace: posting.workplace,
                  salary: posting.salary,
                  employmentType: posting.employmentType,
                ),
                const SizedBox(height: 9),
                _CommunityDeadlineLine(
                  label: posting.deadlineLabel,
                  isClosed: posting.isClosed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityUserSourceLabel extends StatelessWidget {
  const _CommunityUserSourceLabel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.placeTagBadge,
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          '사용자 작성',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.communityMetaText,
          ),
        ),
      ),
    );
  }
}

class _CommunityClosedBadge extends StatelessWidget {
  const _CommunityClosedBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          '마감',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.communityMetaText,
          ),
        ),
      ),
    );
  }
}

class _CommunityJobMetaLine extends StatelessWidget {
  final String? wage;
  final String? workingTime;

  const _CommunityJobMetaLine({this.wage, this.workingTime});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (wage != null) ...[
          const Icon(
            Icons.payments_outlined,
            size: 16,
            color: AppColors.uploadButton,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              wage!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.communityText,
              ),
            ),
          ),
        ],
        if (wage != null && workingTime != null) ...[
          const SizedBox(width: 12),
          const _CommunityMetaDot(),
          const SizedBox(width: 12),
        ],
        if (workingTime != null)
          Expanded(
            child: Text(
              workingTime!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: AppColors.communityMetaText,
              ),
            ),
          ),
      ],
    );
  }
}

class _CommunityApiInfoLine extends StatelessWidget {
  final String? workplace;
  final String? salary;
  final String? employmentType;

  const _CommunityApiInfoLine({
    this.workplace,
    this.salary,
    this.employmentType,
  });

  @override
  Widget build(BuildContext context) {
    final values = [workplace, salary, employmentType]
        .whereType<String>()
        .where((String value) => value.trim().isNotEmpty)
        .toList(growable: false);
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: values
          .map(
            (String value) => DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.communityText,
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _CommunityDeadlineLine extends StatelessWidget {
  final String label;
  final bool isClosed;

  const _CommunityDeadlineLine({required this.label, required this.isClosed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.event_outlined,
          size: 16,
          color: isClosed
              ? AppColors.communityMetaText
              : AppColors.uploadButton,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isClosed
                ? AppColors.communityMetaText
                : AppColors.communityText,
          ),
        ),
      ],
    );
  }
}

class _CommunityActionIcon extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final void Function() onTap;

  const _CommunityActionIcon({
    required this.icon,
    required this.onTap,
    this.label,
    this.color = AppColors.communityMetaText,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label ?? '공유',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: color),
              if (label != null) ...[
                const SizedBox(width: 3),
                Text(
                  label!,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityMetaDot extends StatelessWidget {
  const _CommunityMetaDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: AppColors.inputBorder,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CommunityJobSectionEmpty extends StatelessWidget {
  final IconData icon;
  final String message;

  const _CommunityJobSectionEmpty({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: AppColors.unselectedItem),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: AppColors.communityMetaText,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityJobApiError extends StatelessWidget {
  final String message;

  const _CommunityJobApiError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1DFBE)),
      ),
      child: Text(
        '관광인 채용정보를 불러오지 못했어요.\n$message',
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          height: 1.45,
          color: AppColors.communityText,
        ),
      ),
    );
  }
}

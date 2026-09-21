import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/presentation/component/job/community_job_card_components.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityUserJobCard extends StatelessWidget {
  final CommunityPost post;
  final void Function() onTap;
  final void Function() onLike;
  final void Function() onComment;
  final void Function() onShare;

  const CommunityUserJobCard({
    super.key,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isClosed) const CommunityJobClosedBadge(),
                    const SizedBox(width: 4),
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
                  ],
                ),
                const SizedBox(height: 9),
                if (post.jobWageType != null || post.jobWorkingTime != null)
                  CommunityJobMetaLine(
                    wage: _wageLabel,
                    workingTime: post.jobWorkingTime,
                  ),
                const SizedBox(height: 8),
                CommunityJobDeadlineLine(
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
                    CommunityJobActionIcon(
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
                    CommunityJobActionIcon(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: '${post.commentCount}',
                      onTap: onComment,
                    ),
                    const SizedBox(width: 8),
                    CommunityJobActionIcon(
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

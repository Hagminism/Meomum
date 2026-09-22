import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/tour_api_job_posting.dart';
import 'package:meomum/feature/community/presentation/component/job/community_job_card_components.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityTourJobCard extends StatelessWidget {
  final TourApiJobPosting posting;
  final void Function() onTap;

  const CommunityTourJobCard({
    super.key,
    required this.posting,
    required this.onTap,
  });

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
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD9E7D2)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (posting.companyName != null) ...[
                      Text(
                        posting.companyName!,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.uploadButton,
                        ),
                      ),
                      const Spacer(),
                    ],
                    if (posting.isClosed)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: CommunityJobClosedBadge(),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                CommunityJobApiInfoLine(
                  workplace: posting.workplace,
                  salary: posting.salary,
                  employmentType: posting.employmentType,
                ),
                const SizedBox(height: 9),
                CommunityJobDeadlineLine(
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

class CommunityJobApiInfoLine extends StatelessWidget {
  final String? workplace;
  final String? salary;
  final String? employmentType;

  const CommunityJobApiInfoLine({
    super.key,
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
                color: AppColors.black.withValues(alpha: 0.04),
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

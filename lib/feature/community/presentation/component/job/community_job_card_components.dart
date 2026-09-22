import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityJobUserSourceLabel extends StatelessWidget {
  const CommunityJobUserSourceLabel({super.key});

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

class CommunityJobClosedBadge extends StatelessWidget {
  const CommunityJobClosedBadge({super.key});

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

class CommunityJobMetaLine extends StatelessWidget {
  final String? wage;
  final String? workingTime;

  const CommunityJobMetaLine({
    super.key,
    this.wage,
    this.workingTime,
  });

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
          const CommunityJobMetaDot(),
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

class CommunityJobDeadlineLine extends StatelessWidget {
  final String label;
  final bool isClosed;

  const CommunityJobDeadlineLine({
    super.key,
    required this.label,
    required this.isClosed,
  });

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

class CommunityJobActionIcon extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final void Function() onTap;

  const CommunityJobActionIcon({
    super.key,
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

class CommunityJobMetaDot extends StatelessWidget {
  const CommunityJobMetaDot({super.key});

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

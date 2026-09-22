class CommunityJobWageTypes {
  const CommunityJobWageTypes._();

  static const List<String> values = <String>[
    '시급',
    '일급',
    '주급',
    '월급',
    '건당',
    '협의',
  ];
}

class CommunityJobPosting {
  final String id;
  final String authorId;
  final String upperRegion;
  final String lowerRegion;
  final String nickname;
  final DateTime createdAt;
  final String title;
  final String content;
  final String? wageType;
  final double? wageAmount;
  final String? workingTime;
  final DateTime? recruitmentDeadline;
  final bool isAlwaysRecruiting;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final String? profileImageUrl;

  const CommunityJobPosting({
    required this.id,
    required this.authorId,
    required this.upperRegion,
    required this.lowerRegion,
    required this.nickname,
    required this.createdAt,
    required this.title,
    required this.content,
    this.wageType,
    this.wageAmount,
    this.workingTime,
    this.recruitmentDeadline,
    this.isAlwaysRecruiting = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.profileImageUrl,
  });

  bool get isClosed =>
      !isAlwaysRecruiting &&
      recruitmentDeadline != null &&
      DateUtils.dateOnly(recruitmentDeadline!).isBefore(
        DateUtils.dateOnly(DateTime.now()),
      );

  String get deadlineLabel {
    if (isAlwaysRecruiting) return '상시 모집';
    final deadline = recruitmentDeadline;
    if (deadline == null) return '마감일 미정';
    return '${deadline.year}.${deadline.month.toString().padLeft(2, '0')}.${deadline.day.toString().padLeft(2, '0')} 마감';
  }

  String? get wageLabel {
    if (wageType == null || wageType!.isEmpty) return null;
    if (wageType == '협의') return '급여 협의';
    final amount = wageAmount;
    if (amount == null) return wageType;
    final formatted = amount == amount.truncateToDouble()
        ? amount.toInt().toString()
        : amount.toString();
    return '$wageType $formatted원';
  }
}

class DateUtils {
  const DateUtils._();

  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

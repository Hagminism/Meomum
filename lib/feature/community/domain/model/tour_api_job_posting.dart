class TourApiJobPosting {
  final String empmnInfoNo;
  final String upperRegion;
  final String lowerRegion;
  final String? companyName;
  final String title;
  final String? workplace;
  final String? salary;
  final String? wageType;
  final String? employmentType;
  final String? careerCondition;
  final String? recruitmentCount;
  final String? workingTime;
  final DateTime? recruitmentDeadline;
  final bool isAlwaysRecruiting;
  final DateTime? registeredAt;
  final DateTime? modifiedAt;
  final String? originalUrl;
  final Map<String, dynamic>? detailPayload;

  const TourApiJobPosting({
    required this.empmnInfoNo,
    required this.upperRegion,
    required this.lowerRegion,
    required this.title,
    this.companyName,
    this.workplace,
    this.salary,
    this.wageType,
    this.employmentType,
    this.careerCondition,
    this.recruitmentCount,
    this.workingTime,
    this.recruitmentDeadline,
    this.isAlwaysRecruiting = false,
    this.registeredAt,
    this.modifiedAt,
    this.originalUrl,
    this.detailPayload,
  });

  bool get isClosed =>
      !isAlwaysRecruiting &&
      recruitmentDeadline != null &&
      DateTime(
        recruitmentDeadline!.year,
        recruitmentDeadline!.month,
        recruitmentDeadline!.day,
      ).isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );

  String get deadlineLabel {
    if (isAlwaysRecruiting) return '상시 모집';
    final deadline = recruitmentDeadline;
    if (deadline == null) return '마감일 미정';
    return '${deadline.year}.${deadline.month.toString().padLeft(2, '0')}.${deadline.day.toString().padLeft(2, '0')} 마감';
  }

  TourApiJobPosting copyWith({Map<String, dynamic>? detailPayload}) {
    return TourApiJobPosting(
      empmnInfoNo: empmnInfoNo,
      upperRegion: upperRegion,
      lowerRegion: lowerRegion,
      companyName: companyName,
      title: title,
      workplace: workplace,
      salary: salary,
      wageType: wageType,
      employmentType: employmentType,
      careerCondition: careerCondition,
      recruitmentCount: recruitmentCount,
      workingTime: workingTime,
      recruitmentDeadline: recruitmentDeadline,
      isAlwaysRecruiting: isAlwaysRecruiting,
      registeredAt: registeredAt,
      modifiedAt: modifiedAt,
      originalUrl: originalUrl,
      detailPayload: detailPayload ?? this.detailPayload,
    );
  }
}

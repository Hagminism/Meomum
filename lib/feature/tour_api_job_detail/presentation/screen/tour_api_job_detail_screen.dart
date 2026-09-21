import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/community/domain/model/tour_api_job_posting.dart';
import 'package:meomum/feature/tour_api_job_detail/presentation/screen/tour_api_job_detail_action.dart';
import 'package:meomum/feature/tour_api_job_detail/presentation/screen/tour_api_job_detail_state.dart';
import 'package:meomum/ui/app_colors.dart';

class TourApiJobDetailScreen extends StatelessWidget {
  final TourApiJobDetailState state;
  final void Function(TourApiJobDetailAction action) onAction;

  const TourApiJobDetailScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final posting = state.posting;
    if (state.isLoading && posting == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF63C77E)),
        ),
      );
    }
    if (posting == null) {
      return Scaffold(
        body: Center(
          child: Text(state.errorMessage ?? '채용정보를 불러오지 못했습니다.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: CustomAppBar(
        title: '관광인 채용정보',
        titleColor: AppColors.communityText,
        showBackButton: true,
        onBackPressed: () => onAction(const TapBack()),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(posting),
                  const SizedBox(height: 14),
                  _buildSummary(posting),
                  const SizedBox(height: 18),
                  if (state.isDetailLoading) _buildDetailLoading(),
                  if (state.detailErrorMessage != null)
                    _buildDetailError(state.detailErrorMessage!),
                  if (!state.isDetailLoading &&
                      state.detailErrorMessage == null)
                    ..._buildDetailSections(state.detail),
                  if (posting.originalUrl != null ||
                      _detailValue(state.detail, ['tursmEmpmnInfoURL']) !=
                          null) ...[
                    const SizedBox(height: 22),
                    _buildOriginalLink(),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TourApiJobPosting posting) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E7D2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              posting.title,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 22,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: AppColors.communityText,
              ),
            ),
            if (posting.companyName != null) ...[
              const SizedBox(height: 8),
              Text(
                posting.companyName!,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.communityMetaText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(TourApiJobPosting posting) {
    final items = <_DetailInfo>[
      if (posting.workplace != null) _DetailInfo('근무 지역', posting.workplace!),
      if (posting.salary != null)
        _DetailInfo('급여', _joinValues([posting.wageType, posting.salary])!),
      if (posting.employmentType != null)
        _DetailInfo('고용 형태', posting.employmentType!),
      if (posting.careerCondition != null)
        _DetailInfo('경력 조건', posting.careerCondition!),
      if (posting.recruitmentCount != null)
        _DetailInfo('모집 인원', posting.recruitmentCount!),
      if (posting.workingTime != null)
        _DetailInfo('근무 시간', posting.workingTime!),
      _DetailInfo('모집 마감', posting.deadlineLabel),
    ];

    return _buildSection(
      title: '모집 요약',
      child: Column(
        children: items
            .asMap()
            .entries
            .map(
              (MapEntry<int, _DetailInfo> entry) => Column(
                children: [
                  if (entry.key > 0)
                    const Divider(height: 1, color: AppColors.divider),
                  _buildInfoRow(entry.value),
                ],
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  List<Widget> _buildDetailSections(Map<String, dynamic>? detail) {
    final sections = <Widget>[];
    final values = <String, List<String>>{
      '채용 내용': [
        'dtyCn',
        'empmnCont',
        'empmnContent',
        'jobDescription',
        'description',
      ],
      '우대 사항': ['etcPfrtMtrCn', 'preferCont', 'preferred', 'preferCondition'],
      '자격·교육': [
        'qlfcLcnsCn',
        'majorNm',
        'license',
        'education',
        'educationCondition',
      ],
      '전형 절차': ['stcsMthCn', 'process', 'empmnProcess', 'selectionProcess'],
      '제출 서류': ['sbmsnDocuCn', 'document', 'documents', 'submitDocument'],
      '복리후생': ['wlfareEtcCn', 'benefit', 'benefits', 'welfare'],
      '기업 소개': ['coIntroCn', 'corpIntro', 'companyIntro', 'companyDescription'],
    };

    for (final MapEntry<String, List<String>> entry in values.entries) {
      final value = _detailValue(detail, entry.value);
      if (value == null) continue;
      sections.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildSection(
            title: entry.key,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                height: 1.6,
                color: AppColors.communityText,
              ),
            ),
          ),
        ),
      );
    }
    return sections;
  }

  Widget _buildDetailLoading() {
    return _buildSection(
      title: '상세 안내',
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailError(String detailErrorMessage) {
    return _buildSection(
      title: '상세 안내',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상세 내용을 불러오지 못했어요. 기본 채용정보는 확인할 수 있습니다.',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              height: 1.45,
              color: AppColors.communityText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detailErrorMessage,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: AppColors.communityMetaText,
            ),
          ),
          const SizedBox(height: 12),
          _OutlineActionButton(
            label: '다시 시도',
            onTap: () => onAction(const TapRetryDetail()),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalLink() {
    return _OutlineActionButton(
      label: '관광인 원문 보기',
      icon: Icons.open_in_new_rounded,
      onTap: () => onAction(const TapOriginalLink()),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.communityText,
              ),
            ),
            const SizedBox(height: 11),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(_DetailInfo info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              info.label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: AppColors.communityMetaText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              info.value,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: AppColors.communityText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _detailValue(Map<String, dynamic>? detail, List<String> keys) {
    final source = detail;
    if (source == null) return null;
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  String? _joinValues(List<String?> values) {
    final filtered = values
        .whereType<String>()
        .where((String value) => value.trim().isNotEmpty)
        .toList(growable: false);
    return filtered.isEmpty ? null : filtered.join(' · ');
  }
}

class _DetailInfo {
  final String label;
  final String value;

  const _DetailInfo(this.label, this.value);
}

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final void Function() onTap;

  const _OutlineActionButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.uploadButton),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.uploadButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

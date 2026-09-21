import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/feature/community/domain/model/community_job_posting.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityJobFormFields extends StatelessWidget {
  final String? wageType;
  final String wageAmount;
  final String workingTime;
  final DateTime? recruitmentDeadline;
  final bool isAlwaysRecruiting;
  final bool enabled;
  final void Function(String?) onWageTypeChanged;
  final void Function(String) onWageAmountChanged;
  final void Function(String) onWorkingTimeChanged;
  final void Function() onRecruitmentDeadlineTap;
  final void Function() onAlwaysRecruitingToggle;

  const CommunityJobFormFields({
    super.key,
    required this.wageType,
    required this.wageAmount,
    required this.workingTime,
    required this.recruitmentDeadline,
    required this.isAlwaysRecruiting,
    required this.enabled,
    required this.onWageTypeChanged,
    required this.onWageAmountChanged,
    required this.onWorkingTimeChanged,
    required this.onRecruitmentDeadlineTap,
    required this.onAlwaysRecruitingToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('급여'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildWageTypeField(context)),
            if (wageType != null && wageType != '협의') ...[
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  hintText: '금액',
                  value: wageAmount,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: onWageAmountChanged,
                ),
              ),
            ],
          ],
        ),
        if (wageType == '협의')
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '급여 금액은 본문에서 협의 내용을 안내할 수 있어요.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: 20),
        _buildLabel('근무 시간'),
        const SizedBox(height: 8),
        _buildTextField(
          hintText: '예: 월~금 09:00~18:00',
          value: workingTime,
          onChanged: onWorkingTimeChanged,
        ),
        const SizedBox(height: 20),
        _buildLabel('모집 마감'),
        const SizedBox(height: 8),
        _buildDeadlineField(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildWageTypeField(BuildContext context) {
    return _buildSelectField(
      label: wageType ?? '급여 형태 선택',
      onTap: enabled ? () => _showWageTypeSheet(context) : null,
    );
  }

  Widget _buildDeadlineField() {
    return Row(
      children: [
        Expanded(
          child: _buildSelectField(
            label: isAlwaysRecruiting
                ? '상시 모집'
                : recruitmentDeadline == null
                ? '마감일 선택'
                : _formatDate(recruitmentDeadline!),
            onTap: enabled && !isAlwaysRecruiting
                ? onRecruitmentDeadlineTap
                : null,
            muted: isAlwaysRecruiting,
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          label: '상시 모집',
          checked: isAlwaysRecruiting,
          button: true,
          child: InkWell(
            onTap: enabled ? onAlwaysRecruitingToggle : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isAlwaysRecruiting
                    ? AppColors.categoryHighlight
                    : AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAlwaysRecruiting
                      ? AppColors.primary
                      : AppColors.inputBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAlwaysRecruiting
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 18,
                    color: isAlwaysRecruiting
                        ? AppColors.uploadButton
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '상시',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectField({
    required String label,
    required void Function()? onTap,
    bool muted = false,
  }) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: muted
                ? AppColors.categoryHighlight
                : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: muted || label != '급여 형태 선택'
                        ? AppColors.black
                        : AppColors.placeholderText,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.hintIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required String value,
    required void Function(String) onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: TextFormField(
        initialValue: value,
        enabled: enabled,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 15,
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            color: AppColors.placeholderText,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Future<void> _showWageTypeSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: AppColors.writeBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '급여 형태',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ),
                ...CommunityJobWageTypes.values.map(
                  (String type) => _buildWageTypeOption(sheetContext, type),
                ),
                _buildWageTypeOption(sheetContext, '선택 안 함', value: null),
              ],
            ),
          ),
        );
      },
    );

    if (context.mounted && selected != null) {
      onWageTypeChanged(selected == '선택 안 함' ? null : selected);
    }
  }

  Widget _buildWageTypeOption(
    BuildContext context,
    String label, {
    String? value,
  }) {
    final actualValue = value ?? label;
    final isSelected =
        wageType == actualValue ||
        (actualValue == '선택 안 함' && wageType == null);
    return InkWell(
      onTap: () => Navigator.of(context).pop(actualValue),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  color: AppColors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, color: AppColors.uploadButton),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

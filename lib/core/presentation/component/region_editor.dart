import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class RegionEditor extends StatelessWidget {
  final String title;
  final String description;
  final String? selectedRegionLabel;
  final bool isLoading;
  final bool isValid;
  final String submitLabel;
  final void Function() onRegionFieldTap;
  final void Function() onBack;
  final void Function() onSubmit;

  const RegionEditor({
    super.key,
    required this.title,
    required this.description,
    required this.selectedRegionLabel,
    required this.isLoading,
    required this.isValid,
    required this.submitLabel,
    required this.onRegionFieldTap,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 32,
              fontWeight: FontWeight.w600,
              height: 1,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.4,
              letterSpacing: -0.36,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 50),
          InkWell(
            onTap: isLoading ? null : onRegionFieldTap,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: AppColors.inputBorder),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedRegionLabel == null
                          ? '지역을 선택해주세요'
                          : selectedRegionLabel!,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: selectedRegionLabel == null
                            ? AppColors.textSecondary
                            : AppColors.black,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.black,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 50,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : onBack,
                  label: const Text(
                    '뒤로',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.inputBackground,
                    foregroundColor: AppColors.black,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: isLoading || !isValid ? null : onSubmit,
                    label: Text(
                      submitLabel,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.uploadButton,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

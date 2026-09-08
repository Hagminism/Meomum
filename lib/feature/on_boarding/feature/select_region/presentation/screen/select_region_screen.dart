import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/on_boarding/feature/select_region/presentation/screen/select_region_action.dart';
import 'package:meomum/feature/on_boarding/feature/select_region/presentation/screen/select_region_state.dart';
import 'package:meomum/ui/app_colors.dart';

class SelectRegionScreen extends StatelessWidget {
  final SelectRegionState state;
  final void Function(SelectRegionAction) onAction;

  const SelectRegionScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final selectedRegion = state.selectedRegion;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '거주 지역을 선택해주세요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '선택한 지역의 커뮤니티를 먼저 보여드릴게요.',
                  style: TextStyle(
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
                  onTap: state.isLoading
                      ? null
                      : () {
                          onAction(
                            const SelectRegionAction.tapRegionField(),
                          );
                        },
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
                            selectedRegion == null
                                ? '지역을 선택해주세요'
                                : _regionLabel(selectedRegion),
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: selectedRegion == null
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
                        onPressed: state.isLoading
                            ? null
                            : () {
                                onAction(
                                  const SelectRegionAction.tapBack(),
                                );
                              },
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
                          onPressed: state.isLoading || !state.isValid
                              ? null
                              : () {
                                  onAction(
                                    const SelectRegionAction.tapSubmit(),
                                  );
                                },
                          label: const Text(
                            '이 지역을 선택할게요',
                            style: TextStyle(
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
          ),
        ),
      ),
    );
  }

  String _regionLabel(CommunityRegion region) {
    return '${region.upperRegion} ${region.lowerRegion}';
  }
}

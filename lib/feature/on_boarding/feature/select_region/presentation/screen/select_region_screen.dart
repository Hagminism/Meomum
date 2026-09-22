import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/core/presentation/component/region_editor.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          child: RegionEditor(
            title: '거주 지역을 선택해주세요',
            description: '선택한 지역의 커뮤니티를 먼저 보여드릴게요.',
            selectedRegionLabel: state.selectedRegion == null
                ? null
                : '${state.selectedRegion!.upperRegion} '
                      '${state.selectedRegion!.lowerRegion}',
            isLoading: state.isLoading,
            isValid: state.isValid,
            submitLabel: '이 지역을 선택할게요',
            onRegionFieldTap: () {
              onAction(const SelectRegionAction.tapRegionField());
            },
            onBack: () {
              onAction(const SelectRegionAction.tapBack());
            },
            onSubmit: () {
              onAction(const SelectRegionAction.tapSubmit());
            },
          ),
        ),
      ),
    );
  }
}

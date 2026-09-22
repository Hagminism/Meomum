import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/core/presentation/component/region_editor.dart';
import 'package:meomum/feature/edit_region/presentation/screen/edit_region_action.dart';
import 'package:meomum/feature/edit_region/presentation/screen/edit_region_state.dart';
import 'package:meomum/ui/app_colors.dart';

class EditRegionScreen extends StatelessWidget {
  final EditRegionState state;
  final void Function(EditRegionAction) onAction;

  const EditRegionScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: state.isLoading ? false : true,
        child: Scaffold(
          backgroundColor: AppColors.homeBackground,
          body: SafeArea(
            child: RegionEditor(
              title: '거주 지역을 수정해보세요',
              description: '선택한 지역을 기준으로 커뮤니티를 보여드릴게요.',
              selectedRegionLabel: state.selectedRegion == null
                  ? null
                  : '${state.selectedRegion!.upperRegion} '
                        '${state.selectedRegion!.lowerRegion}',
              isLoading: state.isLoading,
              isValid: state.isValid,
              submitLabel: '변경사항을 저장할게요',
              onRegionFieldTap: () {
                onAction(const EditRegionAction.tapRegionField());
              },
              onBack: () {
                onAction(const EditRegionAction.tapBack());
              },
              onSubmit: () {
                onAction(const EditRegionAction.tapSubmit());
              },
            ),
          ),
        ),
      ),
    );
  }
}

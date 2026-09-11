import 'package:flutter/material.dart';
import 'package:meomum/feature/map/presentation/component/drawer/map_current_location_button.dart';
import 'package:meomum/feature/map/presentation/component/drawer/map_research_button.dart';

/// 드로어 주변에 현재 위치와 재검색 컨트롤을 배치합니다.
///
/// 컨트롤이 숨겨진 동안 지도 터치를 가로채지 않도록 포인터 입력도 함께 차단합니다.
class MapBottomDrawerControls extends StatelessWidget {
  final bool isVisible;
  final bool isResearchEnabled;
  final bool isResearchLoading;
  final double currentLocationBottom;
  final double researchButtonTop;
  final double controlHeight;
  final void Function() onCurrentLocationPressed;
  final void Function() onResearchPressed;

  const MapBottomDrawerControls({
    super.key,
    required this.isVisible,
    required this.isResearchEnabled,
    required this.isResearchLoading,
    required this.currentLocationBottom,
    required this.researchButtonTop,
    required this.controlHeight,
    required this.onCurrentLocationPressed,
    required this.onResearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 현재 위치 버튼은 드로어의 상단을 따라 이동합니다.
        Positioned(
          right: 16,
          bottom: currentLocationBottom,
          width: controlHeight,
          height: controlHeight,
          child: IgnorePointer(
            ignoring: !isVisible,
            child: AnimatedOpacity(
              opacity: isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 50),
              child: MapCurrentLocationButton(
                onTap: onCurrentLocationPressed,
              ),
            ),
          ),
        ),
        // 재검색 버튼은 상단 검색창 아래의 고정된 위치에 표시합니다.
        Positioned(
          top: researchButtonTop,
          left: 0,
          right: 0,
          height: controlHeight,
          child: IgnorePointer(
            ignoring: !isVisible,
            child: AnimatedOpacity(
              opacity: isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 50),
              child: Center(
                child: MapResearchButton(
                  isEnabled: isResearchEnabled,
                  isLoading: isResearchLoading,
                  onTap: onResearchPressed,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

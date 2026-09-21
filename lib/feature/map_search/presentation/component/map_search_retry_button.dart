import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class MapSearchRetryButton extends StatefulWidget {
  final void Function() onTap;

  const MapSearchRetryButton({
    super.key,
    required this.onTap,
  });

  @override
  State<MapSearchRetryButton> createState() => _MapSearchRetryButtonState();
}

class _MapSearchRetryButtonState extends State<MapSearchRetryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: '검색 다시 시도',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(
            minWidth: 124,
            minHeight: 48,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.homeBackground,
            border: Border.all(
              color: AppColors.primary,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Text(
              '다시 시도',
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }
}

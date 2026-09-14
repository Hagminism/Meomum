import 'package:flutter/material.dart';

/// 설정 화면의 모든 상호작용 행에 동일한 눌림 피드백과 접근성 정보를 제공합니다.
class SettingsInteractiveRow extends StatelessWidget {
  final Widget child;
  final String semanticLabel;
  final void Function() onTap;
  final bool? expanded;
  final double minHeight;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final BoxBorder? border;

  const SettingsInteractiveRow({
    super.key,
    required this.child,
    required this.semanticLabel,
    required this.onTap,
    this.expanded,
    this.minHeight = 48,
    this.backgroundColor = Colors.transparent,
    this.borderRadius = BorderRadius.zero,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      expanded: expanded,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: border,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

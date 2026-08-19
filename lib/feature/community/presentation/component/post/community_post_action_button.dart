import 'package:flutter/material.dart';

class CommunityPostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final void Function() onPressed;

  const CommunityPostActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

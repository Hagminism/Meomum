import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityProfileAvatar extends StatelessWidget {
  final String? imageUrl;

  const CommunityProfileAvatar({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 44,
        height: 44,
        child: imageUrl == null
            ? const ColoredBox(color: AppColors.profileAvatarPlaceholder)
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return const ColoredBox(
                        color: AppColors.profileAvatarPlaceholder,
                      );
                    },
              ),
      ),
    );
  }
}

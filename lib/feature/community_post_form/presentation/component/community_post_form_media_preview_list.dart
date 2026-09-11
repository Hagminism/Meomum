import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meomum/feature/community_post_form/presentation/model/community_post_form_media.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostFormMediaPreviewList extends StatelessWidget {
  final List<CommunityPostFormMedia> mediaItems;
  final void Function(int) onRemove;

  const CommunityPostFormMediaPreviewList({
    super.key,
    required this.mediaItems,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: List.generate(mediaItems.length, (index) {
        final media = mediaItems[index];
        final path = media.path.toLowerCase();
        final isVideo = path.endsWith('.mp4') || path.endsWith('.mov');
        final ImageProvider<Object> imageProvider = media.isLocal
            ? FileImage(File(media.localFile!.path))
            : NetworkImage(media.existingImage!.publicUrl);

        return Padding(
          padding: EdgeInsets.only(
            right: index == mediaItems.length - 1 ? 0 : 10,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.inputBorder,
                    width: 1,
                  ),
                  image: !isVideo
                      ? DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: isVideo ? AppColors.black : null,
                ),
                child: isVideo
                    ? const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: AppColors.white,
                          size: 36,
                        ),
                      )
                    : null,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onRemove(index),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0x99000000),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

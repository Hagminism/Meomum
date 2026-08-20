import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/ui/app_colors.dart';

class MediaPreviewList extends StatelessWidget {
  final List<XFile> mediaFiles;
  final void Function(int) onRemove;

  const MediaPreviewList({
    super.key,
    required this.mediaFiles,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: List.generate(mediaFiles.length, (index) {
        final file = mediaFiles[index];
        final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
            file.path.toLowerCase().endsWith('.mov');

        return Padding(
          padding: EdgeInsets.only(
            right: index == mediaFiles.length - 1 ? 0 : 10,
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
                          image: FileImage(File(file.path)),
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

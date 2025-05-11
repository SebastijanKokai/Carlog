import 'dart:io';
import 'package:carlog/widgets/image_picker/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:carlog/extensions/theme_extensions.dart';
import 'package:carlog/widgets/image_picker/image_picker_button.dart';

class ImagePickerSection extends StatelessWidget {
  const ImagePickerSection({
    super.key,
    required this.image,
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  final File? image;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colorScheme.primaryContainer.withAlpha(26),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          ImagePreview(image: image),
          const SizedBox(height: 16),
          Row(
            children: [
              ImagePickerButton(
                onPressed: onCameraPressed,
                icon: Icons.camera_alt,
                label: 'KAMERA',
              ),
              const SizedBox(width: 16),
              ImagePickerButton(
                onPressed: onGalleryPressed,
                icon: Icons.photo_library,
                label: 'GALERIJA',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

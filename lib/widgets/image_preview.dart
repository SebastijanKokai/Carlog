import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carlog/extensions/theme_extensions.dart';

class ImagePreview extends StatelessWidget {
  final File? image;
  final double height;
  final double width;
  final String placeholderText;
  final double iconSize;
  final double borderRadius;
  final BoxFit fit;

  const ImagePreview({
    super.key,
    this.image,
    this.height = 200,
    this.width = double.infinity,
    this.placeholderText = 'Dodaj sliku',
    this.iconSize = 48,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return _ImagePreviewContent(
        image: image!,
        height: height,
        width: width,
        borderRadius: borderRadius,
        fit: fit,
      );
    }

    return _ImagePlaceholder(
      height: height,
      width: width,
      borderRadius: borderRadius,
      placeholderText: placeholderText,
      iconSize: iconSize,
    );
  }
}

class _ImagePreviewContent extends StatelessWidget {
  final File image;
  final double height;
  final double width;
  final double borderRadius;
  final BoxFit fit;

  const _ImagePreviewContent({
    required this.image,
    required this.height,
    required this.width,
    required this.borderRadius,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        image,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _ImageErrorPlaceholder(
            height: height,
            width: width,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final String placeholderText;
  final double iconSize;

  const _ImagePlaceholder({
    required this.height,
    required this.width,
    required this.borderRadius,
    required this.placeholderText,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: context.outlineColor,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: iconSize,
              color: context.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              placeholderText,
              style: TextStyle(
                color: context.primaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const _ImageErrorPlaceholder({
    required this.height,
    required this.width,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: context.outlineColor,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Greška pri učitavanju slike',
              style: TextStyle(
                color: context.colorScheme.error,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

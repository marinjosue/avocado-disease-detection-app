import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class ImagePreview extends StatelessWidget {
  final String imagePath;
  final double height;
  final BorderRadius? borderRadius;

  const ImagePreview({
    Key? key,
    required this.imagePath,
    this.height = 200,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyLight,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.greyLight,
              child: const Icon(
                Icons.image_not_supported,
                color: AppColors.grey,
                size: 50,
              ),
            );
          },
        ),
      ),
    );
  }
}

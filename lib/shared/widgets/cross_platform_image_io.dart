import 'dart:io';
import 'package:flutter/material.dart';

/// Mobile/Desktop implementation for image display
Widget buildPlatformImage({
  required dynamic imageData,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
  Widget? loadingWidget,
}) {
  if (imageData is File) {
    return Image.file(
      imageData,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }
  
  return errorWidget ?? Container(
    width: width,
    height: height,
    color: Colors.grey[300],
    child: const Icon(Icons.error, color: Colors.red),
  );
}


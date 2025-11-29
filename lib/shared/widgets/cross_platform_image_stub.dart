import 'package:flutter/material.dart';

Widget buildPlatformImage({
  required dynamic imageData,
  double? width,
  double? height,
  BoxFit? fit,
  Widget? errorWidget,
  Widget? loadingWidget,
}) {
  // Fallback implementation for unsupported platforms
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(
      Icons.image_not_supported,
      color: Colors.grey,
      size: 32,
    ),
  );
}

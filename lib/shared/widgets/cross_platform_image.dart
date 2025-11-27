import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Conditional imports for platform-specific image handling
import 'cross_platform_image_stub.dart'
    if (dart.library.io) 'cross_platform_image_io.dart'
    if (dart.library.html) 'cross_platform_image_web.dart';

/// Cross-platform image widget that handles both File and Uint8List
class CrossPlatformImage extends StatelessWidget {
  final dynamic imageData; // Can be File or Uint8List
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const CrossPlatformImage({
    super.key,
    required this.imageData,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageData == null) {
      return errorWidget ?? _buildErrorWidget();
    }

    try {
      return buildPlatformImage(
        imageData: imageData,
        width: width,
        height: height,
        fit: fit,
        errorWidget: errorWidget ?? _buildErrorWidget(),
        loadingWidget: loadingWidget,
      );
    } catch (e) {
      return errorWidget ?? _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}

/// Helper class for image data validation
class ImageDataHelper {
  static bool isValidImageData(dynamic imageData) {
    if (kIsWeb) {
      return imageData is Uint8List;
    } else {
      return imageData.runtimeType.toString() == 'File';
    }
  }

  static String getImageType(dynamic imageData) {
    if (kIsWeb) {
      return imageData is Uint8List ? 'Uint8List' : 'Unknown';
    } else {
      return imageData.runtimeType.toString();
    }
  }
}


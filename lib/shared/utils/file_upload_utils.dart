import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Conditional imports for platform-specific file handling
import 'file_upload_stub.dart'
    if (dart.library.io) 'file_upload_io.dart'
    if (dart.library.html) 'file_upload_web.dart';

/// Cross-platform file upload utility that handles both web and mobile environments
class FileUploadUtils {
  /// Create a multipart file from platform-specific file data
  static Future<http.MultipartFile> createMultipartFile({
    required String fieldName,
    required dynamic fileData,
    required String filename,
    String? contentType,
  }) async {
    return await createMultipartFileImpl(
      fieldName: fieldName,
      fileData: fileData,
      filename: filename,
      contentType: contentType,
    );
  }

  /// Get file bytes from platform-specific file data
  static Future<Uint8List> getFileBytes(dynamic fileData) async {
    return await getFileBytesImpl(fileData);
  }

  /// Check if the file data is valid for the current platform
  static bool isValidFileData(dynamic fileData) {
    if (kIsWeb) {
      return fileData is Uint8List;
    } else {
      return fileData.runtimeType.toString() == 'File';
    }
  }

  /// Get a safe filename for the file
  static String getSafeFilename(dynamic fileData, int index) {
    if (kIsWeb) {
      return 'image_$index.jpg';
    } else {
      try {
        return fileData.path.split('/').last;
      } catch (e) {
        return 'image_$index.jpg';
      }
    }
  }
}


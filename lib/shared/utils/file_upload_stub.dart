import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Stub implementation - should not be used
Future<http.MultipartFile> createMultipartFileImpl({
  required String fieldName,
  required dynamic fileData,
  required String filename,
  String? contentType,
}) async {
  throw UnsupportedError('File upload not supported on this platform');
}

Future<Uint8List> getFileBytesImpl(dynamic fileData) async {
  throw UnsupportedError('File operations not supported on this platform');
}


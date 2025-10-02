import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;

/// Web implementation for file uploads
Future<http.MultipartFile> createMultipartFileImpl({
  required String fieldName,
  required dynamic fileData,
  required String filename,
  String? contentType,
}) async {
  if (fileData is Uint8List) {
    // Default to image/jpeg if no content type provided
    final mediaType = contentType != null ? 
      http_parser.MediaType.parse(contentType) : 
      http_parser.MediaType('image', 'jpeg');
      
    return http.MultipartFile.fromBytes(
      fieldName,
      fileData,
      filename: filename,
      contentType: mediaType,
    );
  }
  throw ArgumentError('Expected Uint8List for web file upload');
}

Future<Uint8List> getFileBytesImpl(dynamic fileData) async {
  if (fileData is Uint8List) {
    return fileData;
  }
  throw ArgumentError('Expected Uint8List for web file data');
}


import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;

/// Mobile/Desktop implementation for file uploads
Future<http.MultipartFile> createMultipartFileImpl({
  required String fieldName,
  required dynamic fileData,
  required String filename,
  String? contentType,
}) async {
  if (fileData is File) {
    final mediaType = contentType != null ? 
      http_parser.MediaType.parse(contentType) : 
      null;
      
    return await http.MultipartFile.fromPath(
      fieldName,
      fileData.path,
      filename: filename,
      contentType: mediaType,
    );
  }
  throw ArgumentError('Expected File for mobile file upload');
}

Future<Uint8List> getFileBytesImpl(dynamic fileData) async {
  if (fileData is File) {
    return await fileData.readAsBytes();
  }
  throw ArgumentError('Expected File for mobile file data');
}


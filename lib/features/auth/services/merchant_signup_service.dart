import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../../../shared/utils/platform_utils.dart';
import '../../../shared/utils/file_upload_utils.dart';
import '../models/merchant_signup_data.dart';

// Service class for API operations
class MerchantSignupService {
  static Future<Map<String, dynamic>> signup(
    MerchantSignupData data,
    List<dynamic> imageFiles,
  ) async {
    try {
      print('[MerchantSignupService] Starting signup process');
      print('[MerchantSignupService] Image files count: ${imageFiles.length}');
      
      // Always use multipart request as expected by backend (even without images)
      print('[MerchantSignupService] Creating multipart/form-data request for backend');
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.merchantSignup}');
      print('[MerchantSignupService] Multipart URL: $uri');
      
      final request = http.MultipartRequest('POST', uri);

      // Add the JSON data as 'request' form field with proper Content-Type
      final requestData = data.toJson();
      final jsonString = jsonEncode(requestData);
      
      // Create a multipart file for the JSON data with application/json content type
      final requestPart = http.MultipartFile.fromString(
        'request',
        jsonString,
        contentType: http_parser.MediaType('application', 'json'),
      );
      request.files.add(requestPart);
      print('[MerchantSignupService] Added request part as JSON: $jsonString');

      // Add image files as 'imageFiles' (as expected by @RequestPart("imageFiles"))
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        
        try {
          if (FileUploadUtils.isValidFileData(imageFile)) {
            final filename = FileUploadUtils.getSafeFilename(imageFile, i);
            
            // Create multipart file based on platform
            http.MultipartFile multipartFile;
            
            if (kIsWeb) {
              // For web, imageFile should be Uint8List
              if (imageFile is Uint8List) {
                multipartFile = http.MultipartFile.fromBytes(
                  'imageFiles',
                  imageFile,
                  filename: filename,
                  contentType: http_parser.MediaType('image', 'jpeg'),
                );
              } else {
                throw ArgumentError('Expected Uint8List for web platform');
              }
            } else {
              // For mobile, imageFile should be File
              if (imageFile.runtimeType.toString() == 'File') {
                final stream = http.ByteStream(imageFile.openRead());
                final length = await imageFile.length();
                multipartFile = http.MultipartFile(
                  'imageFiles',
                  stream,
                  length,
                  filename: filename,
                  contentType: http_parser.MediaType('image', 'jpeg'),
                );
              } else {
                throw ArgumentError('Expected File for mobile platform');
              }
            }
            
            request.files.add(multipartFile);
            print('[MerchantSignupService] Added image file $i: $filename');
          }
        } catch (e) {
          print('[MerchantSignupService] Error adding image file $i: $e');
        }
      }

      // Print complete request details before sending
      print('[MerchantSignupService] === REQUEST DETAILS ===');
      print('[MerchantSignupService] Method: ${request.method}');
      print('[MerchantSignupService] URL: ${request.url}');
      print('[MerchantSignupService] Headers: ${request.headers}');
      print('[MerchantSignupService] Fields: ${request.fields}');
      print('[MerchantSignupService] Files count: ${request.files.length}');
      for (int i = 0; i < request.files.length; i++) {
        final file = request.files[i];
        print('[MerchantSignupService] File $i:');
        print('  - Field: ${file.field}');
        print('  - Filename: ${file.filename}');
        print('  - Content-Type: ${file.contentType}');
        print('  - Length: ${file.length}');
      }
      print('[MerchantSignupService] === END REQUEST DETAILS ===');

      // Send the multipart request
      print('[MerchantSignupService] Sending multipart/form-data request with ${request.files.length} files');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('[MerchantSignupService] Response status: ${response.statusCode}');
      print('[MerchantSignupService] Response body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('[MerchantSignupService] Error in signup: $e');
      return {
        'success': false,
        'message': 'Failed to create account: ${e.toString()}',
      };
    }
  }

  static Future<void> registerFCMToken(String jwtToken) async {
    try {
      final decodedToken = JwtDecoder.decode(jwtToken);
      final userId = decodedToken['memberId'];
      final userType = decodedToken['userType'];

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      final deviceType = PlatformUtils.getDeviceType();
      final deviceModel = PlatformUtils.getDeviceModel();
      final appVersion = PlatformUtils.getAppVersion();
      final osVersion = PlatformUtils.getOSVersion();

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.registerFCMToken}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'userId': userId,
          'userType': userType,
          'fcmToken': fcmToken,
          'deviceType': deviceType,
          'deviceModel': deviceModel,
          'appVersion': appVersion,
          'osVersion': osVersion,
        }),
      );

      final data = jsonDecode(response.body);
      if (!data['success']) {
        print('Failed to register FCM token: ${data['message']}');
      }
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }
}

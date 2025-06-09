// lib/fcm_token_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_service.dart';

class FCMTokenPage extends StatefulWidget {
  const FCMTokenPage({super.key});

  @override
  State<FCMTokenPage> createState() => _FCMTokenPageState();
}

class _FCMTokenPageState extends State<FCMTokenPage> {
  final TextEditingController _tokenController = TextEditingController();
  String? _fcmToken;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _getFCMToken() async {
    try {
      String? token = await NotificationService.getToken();
      setState(() {
        _fcmToken = token;
        _tokenController.text = token ?? 'No token received';
      });
      print('FCM Token: $token');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('FCM Token retrieved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting FCM token: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _copyTokenToClipboard() {
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Token'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FCM Token Testing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191010),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenController,
              readOnly: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'FCM Token will appear here...',
                hintStyle: const TextStyle(
                  color: Color(0xFF8B5B5C),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE3D4D4),
                  ),
                ),
                suffixIcon: _fcmToken != null
                    ? IconButton(
                        icon: Icon(Icons.copy, color: Color(0xFF8B5B5C)),
                        onPressed: _copyTokenToClipboard,
                        tooltip: 'Copy token',
                      )
                    : null,
              ),
              style: const TextStyle(
                color: Color(0xFF191010),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _getFCMToken,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9B8BA),
                      foregroundColor: const Color(0xFF191010),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Get FCM Token',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await NotificationService.showTestNotification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Test notification sent')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1E9EA),
                      foregroundColor: const Color(0xFF191010),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Test Notification',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
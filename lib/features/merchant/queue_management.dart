import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/constants/api_endpoints.dart';

class QueueManagement extends StatefulWidget {
  final Map<String, dynamic> queue;

  const QueueManagement({super.key, required this.queue});

  @override
  State<QueueManagement> createState() => _QueueManagementState();
}

class _QueueManagementState extends State<QueueManagement> {
  bool _isLoading = true;
  Map<String, dynamic>? _queueDetails;
  List<Map<String, dynamic>> _topCustomers = [];

  @override
  void initState() {
    super.initState();
    _loadQueueDetails();
  }

  Future<void> _loadQueueDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/queues/${widget.queue['qid']}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _queueDetails = data['data'];
          // TODO: Replace with actual API call to get top customers
          _topCustomers = [
            {
              'name': 'Sophia Clark',
              'reservationId': '12345',
              'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDkVT3HJth0XTIcK5jE3UbA4Qhh5qqp7yltLCeSvXfFJx4CZAXQFHNTO08YsAhZ1A8NdL1L93DINKyu79Gc4cRrzhabgd6yAk_fbbBhEGRULGyRt9QnuhhXixr3cREuKCIyuzOhl0Qo4sfoNZ6XV02DLhGiePx-mKwQK4_Rtp-ageQ7VqWlF_D7CmRE7HsVbD2CjKqAaS2FXN1VCoZfBNLjo1Cr_yn5ODaz5FeQ5gPUSeFrKr99b_hWHcYRmLPTzXvXXOx3DAeOTyYX',
            },
            {
              'name': 'Ethan Miller',
              'reservationId': '67890',
              'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAP0Z6xpxPJiWslyOX09-6xPmtLp1ZLdETtpYEoSFa0T236hZ0Pe_aUdQcT27XF7oiLs8PHa6RtyldKuzk4wGLwrnLw0F9r4e-LZIb7cYkCUQT7FS35EGFZHsMvqsIfifMzYR3uFePxHvMSclE2orO7qeuSV0uTw4lNslVqjShZz3NJlSpKXzylMkzSMCvFVNvKv8uNLZ2zNDPgsbVkCZUGrOjB81UUldbnk3oDxCi5abkf0bg1zqZAItEfAjCVv-iKati8RgGKOYrZ',
            },
            {
              'name': 'Olivia Davis',
              'reservationId': '11223',
              'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAvuyvEXJiIk2WaPj-dnCkHkqoyXqnlG8nSVTW7FVtrH_3Ma8-9UJsLZzSv45JlW2RvNOO1bVBROWBze44pyYtzbufxoWXhaiyKHgp5zAMoOLtesenPkgEKuW6E-eIBtXnZMj3RI4MuLtYz-PpukWYTgTBhra0vw-COklksAg6mXRBRlU6Cloqc7Kzjb-b9ghHn1RCDUHnTfwo20edgpnmMZsi7JFk-qoPGzNndUuL37YkkygewEqcUVZG3dlRvp0Uyh27JeN9a6ESi',
            },
          ];
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to load queue details');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _moveQueueForward() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/${widget.queue['qid']}/process-next'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Queue moved forward successfully'),
            backgroundColor: Color(0xFFE8B4B7),
          ),
        );
        _loadQueueDetails(); // Refresh queue details
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to move queue forward'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF1B0E0E),
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Queue Management',
                      style: TextStyle(
                        color: Color(0xFF1B0E0E),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Top 3 Customers Section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'Top 3 Customers',
                style: TextStyle(
                  color: Color(0xFF1B0E0E),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015,
                ),
              ),
            ),

            // Customer List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _topCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _topCustomers[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(customer['imageUrl']),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer['name'],
                                      style: const TextStyle(
                                        color: Color(0xFF1B0E0E),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Reservation ID: ${customer['reservationId']}',
                                      style: const TextStyle(
                                        color: Color(0xFF994D4F),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF1B0E0E),
                                size: 24,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _moveQueueForward,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE9242A),
                        foregroundColor: const Color(0xFFFCF8F8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Move Queue Forward',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement pause queue
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3E7E8),
                        foregroundColor: const Color(0xFF1B0E0E),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Pause Queue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement stop queue
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3E7E8),
                        foregroundColor: const Color(0xFF1B0E0E),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Stop Queue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 
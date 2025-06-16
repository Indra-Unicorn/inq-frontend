import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/constants/api_endpoints.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<dynamic> _queues = [];

  @override
  void initState() {
    super.initState();
    _loadQueues();
  }

  Future<void> _loadQueues() async {
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
        Uri.parse('${ApiEndpoints.baseUrl}/queues/merchant'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _queues = data['data'];
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to load queues');
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

  Future<void> _showCreateQueueDialog() async {
    final nameController = TextEditingController();
    final maxSizeController = TextEditingController(text: '10');
    final inQoinRateController = TextEditingController(text: '10');
    final alertNumberController = TextEditingController(text: '3');
    final bufferNumberController = TextEditingController(text: '5');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Queue'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Queue Name',
                  hintText: 'Enter queue name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: maxSizeController,
                decoration: const InputDecoration(
                  labelText: 'Max Size',
                  hintText: 'Enter maximum queue size',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: inQoinRateController,
                decoration: const InputDecoration(
                  labelText: 'InQoin Rate',
                  hintText: 'Enter InQoin rate',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: alertNumberController,
                decoration: const InputDecoration(
                  labelText: 'Alert Number',
                  hintText: 'Enter alert number',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bufferNumberController,
                decoration: const InputDecoration(
                  labelText: 'Buffer Number',
                  hintText: 'Enter buffer number',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a queue name')),
                );
                return;
              }

              try {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');

                if (token == null) {
                  throw Exception('Not authenticated');
                }

                final response = await http.post(
                  Uri.parse('${ApiEndpoints.baseUrl}/queues/create'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({
                    'name': nameController.text,
                    'maxSize': int.parse(maxSizeController.text),
                    'inQoinRate': int.parse(inQoinRateController.text),
                    'alertNumber': int.parse(alertNumberController.text),
                    'bufferNumber': int.parse(bufferNumberController.text),
                  }),
                );

                final data = jsonDecode(response.body);
                
                if (response.statusCode == 200 && data['success'] == true) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Queue created successfully'),
                      backgroundColor: Color(0xFFE8B4B7),
                    ),
                  );
                  _loadQueues();
                } else {
                  throw Exception(data['message'] ?? 'Failed to create queue');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _moveQueueForward(String queueId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/process-next'),
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
        _loadQueues(); // Refresh queue list
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
      backgroundColor: const Color(0xFFFBF9F9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: const Text(
                      'Queues',
                      style: TextStyle(
                        color: Color(0xFF191010),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: _showCreateQueueDialog,
                      icon: const Icon(
                        Icons.add,
                        color: Color(0xFF191010),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Active Queues Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Active Queues',
                style: TextStyle(
                  color: Color(0xFF191010),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015,
                ),
              ),
            ),

            // Queue List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _queues.isEmpty
                      ? const Center(
                          child: Text(
                            'No active queues',
                            style: TextStyle(
                              color: Color(0xFF8B5B5C),
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _queues.length,
                          itemBuilder: (context, index) {
                            final queue = _queues[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/queue-management',
                                    arguments: queue,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1E9EA),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.list,
                                              color: Color(0xFF191010),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  queue['name'],
                                                  style: const TextStyle(
                                                    color: Color(0xFF191010),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  'Front: ${queue['frontPerson'] ?? 'No one'}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF8B5B5C),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  '${queue['size']}/${queue['maxSize']} people in line | ${queue['status']}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF8B5B5C),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 32,
                                      child: TextButton(
                                        onPressed: () => _moveQueueForward(queue['qid']),
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color(0xFFF1E9EA),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                        ),
                                        child: const Text(
                                          'Move Queue',
                                          style: TextStyle(
                                            color: Color(0xFF191010),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFF1E9EA),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            
            if (index == 1) {
              Navigator.pushNamed(context, '/merchant-profile');
            }
          },
          backgroundColor: const Color(0xFFFBF9F9),
          selectedItemColor: const Color(0xFF191010),
          unselectedItemColor: const Color(0xFF8B5B5C),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Queues',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
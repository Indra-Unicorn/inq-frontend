import 'package:flutter/material.dart';

class QueueStatusPage extends StatefulWidget {
  const QueueStatusPage({super.key});

  @override
  State<QueueStatusPage> createState() => _QueueStatusPageState();
}

class _QueueStatusPageState extends State<QueueStatusPage> {
  int _selectedIndex = 1; // Set to 1 for Queue tab
  int currentPosition = 3;
  int totalInQueue = 15;
  String estimatedWaitTime = '15 minutes';
  double progressPercentage = 0.2; // 20% progress

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF181111),
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: const Text(
                      'Queue Status',
                      style: TextStyle(
                        color: Color(0xFF181111),
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

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // Main Status Text
                    const Text(
                      'You\'re in the queue',
                      style: TextStyle(
                        color: Color(0xFF181111),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Status Description
                    Text(
                      'Your current position is ${currentPosition}rd in line. The average wait time is approximately $estimatedWaitTime.',
                      style: const TextStyle(
                        color: Color(0xFF181111),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Progress Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Progress Label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Estimated Wait Time',
                                style: TextStyle(
                                  color: Color(0xFF181111),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Progress Bar
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5DCDC),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progressPercentage,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF181111),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Time Label
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              estimatedWaitTime,
                              style: const TextStyle(
                                color: Color(0xFF886364),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Leave Queue Button
                    Container(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: ElevatedButton(
                        onPressed: () {
                          _showLeaveQueueDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4F0F0),
                          foregroundColor: const Color(0xFF181111),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Leave Queue',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.015,
                          ),
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                  ],
                ),
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
              color: Color(0xFFF4F0F0),
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
            
            if (index == 0) {
              Navigator.popUntil(context, ModalRoute.withName('/customer-dashboard'));
            } else if (index == 2) {
              Navigator.pushNamed(context, '/customer-profile');
            }
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF181111),
          unselectedItemColor: const Color(0xFF886364),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Queue',
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

  void _showLeaveQueueDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Leave Queue',
            style: TextStyle(
              color: Color(0xFF181111),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to leave the queue? You will lose your current position.',
            style: TextStyle(
              color: Color(0xFF886364),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF886364),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.popUntil(context, ModalRoute.withName('/customer-dashboard'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Left queue successfully'),
                    backgroundColor: Color(0xFF181111),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              child: const Text('Leave Queue'),
            ),
          ],
        );
      },
    );
  }
}
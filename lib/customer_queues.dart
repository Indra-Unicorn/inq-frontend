import 'package:flutter/material.dart';

class CustomerQueuesPage extends StatefulWidget {
  const CustomerQueuesPage({super.key});

  @override
  State<CustomerQueuesPage> createState() => _CustomerQueuesPageState();
}

class _CustomerQueuesPageState extends State<CustomerQueuesPage> {
  int _selectedIndex = 1; // Set to 1 since this is the "Queues" tab

  final List<ActiveQueue> activeQueues = [
    ActiveQueue(
      storeName: 'Tech Haven',
      estimatedWait: 'Estimated wait: 15 min',
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=100&h=100&fit=crop',
    ),
  ];

  final List<PastQueue> pastQueues = [
    PastQueue(
      storeName: 'Fashion Emporium',
      joinedTime: 'Joined: 10:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=100&h=100&fit=crop',
    ),
    PastQueue(
      storeName: 'Home & Decor',
      joinedTime: 'Joined: 11:30 AM',
      imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=100&h=100&fit=crop',
    ),
  ];

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
                      'Queues',
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active Section
                    if (activeQueues.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Color(0xFF181111),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.015,
                          ),
                        ),
                      ),

                      // Active Queue List
                      ...activeQueues.map((queue) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          leading: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(queue.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            queue.storeName,
                            style: const TextStyle(
                              color: Color(0xFF181111),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            queue.estimatedWait,
                            style: const TextStyle(
                              color: Color(0xFF886364),
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            // Navigate to queue status page
                            Navigator.pushNamed(context, '/queue-status');
                          },
                        ),
                      )),
                    ],

                    // Past Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Past',
                        style: TextStyle(
                          color: Color(0xFF181111),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.015,
                        ),
                      ),
                    ),

                    // Past Queue List
                    ...pastQueues.map((queue) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(queue.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          queue.storeName,
                          style: const TextStyle(
                            color: Color(0xFF181111),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          queue.joinedTime,
                          style: const TextStyle(
                            color: Color(0xFF886364),
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          // Show queue history details
                          print('Show details for ${queue.storeName}');
                        },
                      ),
                    )),

                    const SizedBox(height: 80), // Add bottom padding for navigation bar
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
              Navigator.pop(context);
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

class ActiveQueue {
  final String storeName;
  final String estimatedWait;
  final String imageUrl;

  ActiveQueue({
    required this.storeName,
    required this.estimatedWait,
    required this.imageUrl,
  });
}

class PastQueue {
  final String storeName;
  final String joinedTime;
  final String imageUrl;

  PastQueue({
    required this.storeName,
    required this.joinedTime,
    required this.imageUrl,
  });
}
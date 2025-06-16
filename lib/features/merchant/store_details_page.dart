import 'package:flutter/material.dart';

class StoreDetailsPage extends StatefulWidget {
  final String storeName;
  final String storeAddress;
  final String storeImage;

  const StoreDetailsPage({
    super.key,
    this.storeName = 'Tech Haven',
    this.storeAddress = '123 Main Street, Anytown, USA',
    this.storeImage = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&h=300&fit=crop',
  });

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  int _selectedIndex = 1; // Set to 1 since this is accessed from stores

  final List<StoreQueue> storeQueues = [
    StoreQueue(
      name: 'Customer Service',
      estimatedWait: 'Estimated wait: 15 minutes',
      icon: Icons.people_outline,
    ),
    StoreQueue(
      name: 'Product Returns',
      estimatedWait: 'Estimated wait: 20 minutes',
      icon: Icons.inventory_2_outlined,
    ),
    StoreQueue(
      name: 'New Purchases',
      estimatedWait: 'Estimated wait: 10 minutes',
      icon: Icons.shopping_cart_outlined,
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
                      'Store Details',
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
              child: Column(
                children: [
                  // Store Image Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 218,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(widget.storeImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Color.fromRGBO(0, 0, 0, 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.storeName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Store Address
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.storeAddress,
                      style: const TextStyle(
                        color: Color(0xFF181111),
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Active Queues Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Active Queues',
                      style: TextStyle(
                        color: Color(0xFF181111),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                    ),
                  ),

                  // Queue List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: storeQueues.length,
                      itemBuilder: (context, index) {
                        final queue = storeQueues[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F0F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                queue.icon,
                                color: const Color(0xFF181111),
                                size: 24,
                              ),
                            ),
                            title: Text(
                              queue.name,
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
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF181111),
                              size: 16,
                            ),
                            onTap: () {
                              _joinQueue(queue);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
              Navigator.pushNamed(context, '/customer-queues');
            } else if (index == 3) {
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
              icon: Icon(Icons.storefront),
              label: 'Stores',
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

  void _joinQueue(StoreQueue queue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Join ${queue.name}',
            style: const TextStyle(
              color: Color(0xFF181111),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Do you want to join the ${queue.name} queue at ${widget.storeName}?\n\n${queue.estimatedWait}',
            style: const TextStyle(
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
                // Navigate to queue status page
                Navigator.pushNamed(context, '/queue-status');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Joined ${queue.name} queue at ${widget.storeName}'),
                    backgroundColor: const Color(0xFF181111),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF181111),
                foregroundColor: Colors.white,
              ),
              child: const Text('Join Queue'),
            ),
          ],
        );
      },
    );
  }
}

class StoreQueue {
  final String name;
  final String estimatedWait;
  final IconData icon;

  StoreQueue({
    required this.name,
    required this.estimatedWait,
    required this.icon,
  });
}
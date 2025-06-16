import 'package:flutter/material.dart';
import '../Customer/Screens/dashboard/customer_dashboard.dart';

class StoreDetailsPage extends StatefulWidget {
  final String storeName;
  final String storeAddress;
  final String? storeImage;
  final List<Map<String, dynamic>> queues;

  const StoreDetailsPage({
    super.key,
    required this.storeName,
    required this.storeAddress,
    this.storeImage,
    required this.queues,
  });

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  int _selectedIndex = 1; // Set to 1 since this is accessed from stores

  List<MerchantQueue> get _parsedQueues {
    return widget.queues.map((queue) => MerchantQueue(
      id: queue['id'] as String,
      name: queue['name'] as String,
      merchantId: queue['merchantId'] as String,
      merchantName: queue['merchantName'] as String,
      status: queue['status'] as String,
      processed: queue['processed'] as int,
      size: queue['size'] as int,
      createdAt: DateTime.parse(queue['createdAt'] as String),
      updatedAt: DateTime.parse(queue['updatedAt'] as String),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final queues = _parsedQueues;
    
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
                          color: const Color(0xFFF4F0F0),
                          image: widget.storeImage != null
                              ? DecorationImage(
                                  image: NetworkImage(widget.storeImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
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
                    child: queues.isEmpty
                        ? const Center(
                            child: Text(
                              'No active queues',
                              style: TextStyle(
                                color: Color(0xFF886364),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: queues.length,
                            itemBuilder: (context, index) {
                              final queue = queues[index];
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
                                      _getQueueIcon(queue.name),
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
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Queue Size: ${queue.size}',
                                        style: const TextStyle(
                                          color: Color(0xFF886364),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Processed: ${queue.processed}',
                                        style: const TextStyle(
                                          color: Color(0xFF886364),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: queue.status == 'OPEN'
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFFF44336),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      queue.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () => _joinQueue(queue),
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

  IconData _getQueueIcon(String queueName) {
    final name = queueName.toLowerCase();
    if (name.contains('service')) {
      return Icons.people_outline;
    } else if (name.contains('return')) {
      return Icons.inventory_2_outlined;
    } else if (name.contains('purchase')) {
      return Icons.shopping_cart_outlined;
    } else {
      return Icons.queue_outlined;
    }
  }

  void _joinQueue(MerchantQueue queue) {
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Do you want to join the ${queue.name} queue at ${widget.storeName}?',
                style: const TextStyle(
                  color: Color(0xFF886364),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Current Queue Size: ${queue.size}',
                style: const TextStyle(
                  color: Color(0xFF886364),
                ),
              ),
              Text(
                'Processed: ${queue.processed}',
                style: const TextStyle(
                  color: Color(0xFF886364),
                ),
              ),
            ],
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
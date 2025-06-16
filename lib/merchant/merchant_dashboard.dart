import 'package:flutter/material.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  int _selectedIndex = 0;

  final List<QueueItem> activeQueues = [
    QueueItem(
      name: 'Checkout',
      peopleCount: '10 people in line',
      icon: Icons.list,
    ),
    QueueItem(
      name: 'Returns',
      peopleCount: '5 people in line',
      icon: Icons.list,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        color: Color(0xFF171212),
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
                      onPressed: () {
                        _showAddQueueDialog();
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Color(0xFF171212),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Active Queues Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Active Queues',
                style: TextStyle(
                  color: Color(0xFF171212),
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
                itemCount: activeQueues.length,
                itemBuilder: (context, index) {
                  final queue = activeQueues[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F1F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          queue.icon,
                          color: const Color(0xFF171212),
                          size: 24,
                        ),
                      ),
                      title: Text(
                        queue.name,
                        style: const TextStyle(
                          color: Color(0xFF171212),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        queue.peopleCount,
                        style: const TextStyle(
                          color: Color(0xFF82686A),
                          fontSize: 14,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'manage') {
                            _manageQueue(queue);
                          } else if (value == 'delete') {
                            _deleteQueue(index);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'manage',
                            child: Text('Manage Queue'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete Queue'),
                          ),
                        ],
                        child: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF171212),
                        ),
                      ),
                      onTap: () {
                        _manageQueue(queue);
                      },
                    ),
                  );
                },
              ),
            ),

            // Add some spacing at the bottom
            const SizedBox(height: 20),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFF4F1F1),
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
              // Navigate to Store Profile page
              Navigator.pushNamed(context, '/store-profile');
            }
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF171212),
          unselectedItemColor: const Color(0xFF82686A),
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

  void _showAddQueueDialog() {
    final TextEditingController queueNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add New Queue',
            style: TextStyle(
              color: Color(0xFF171212),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: queueNameController,
            decoration: InputDecoration(
              hintText: 'Enter queue name',
              hintStyle: const TextStyle(
                color: Color(0xFF82686A),
              ),
              filled: true,
              fillColor: const Color(0xFFF4F1F1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(
              color: Color(0xFF171212),
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
                  color: Color(0xFF82686A),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (queueNameController.text.isNotEmpty) {
                  setState(() {
                    activeQueues.add(
                      QueueItem(
                        name: queueNameController.text,
                        peopleCount: '0 people in line',
                        icon: Icons.list,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8B4B7),
                foregroundColor: const Color(0xFF171212),
              ),
              child: const Text('Add Queue'),
            ),
          ],
        );
      },
    );
  }

  void _manageQueue(QueueItem queue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Manage ${queue.name}',
            style: const TextStyle(
              color: Color(0xFF171212),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current status: ${queue.peopleCount}',
                style: const TextStyle(
                  color: Color(0xFF82686A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Queue management options:',
                style: TextStyle(
                  color: Color(0xFF171212),
                  fontWeight: FontWeight.w500,
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
                'Close',
                style: TextStyle(
                  color: Color(0xFF82686A),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement queue management logic
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Managing ${queue.name} queue'),
                    backgroundColor: const Color(0xFFE8B4B7),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8B4B7),
                foregroundColor: const Color(0xFF171212),
              ),
              child: const Text('Manage'),
            ),
          ],
        );
      },
    );
  }

  void _deleteQueue(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Queue',
            style: TextStyle(
              color: Color(0xFF171212),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${activeQueues[index].name}" queue?',
            style: const TextStyle(
              color: Color(0xFF82686A),
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
                  color: Color(0xFF82686A),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  activeQueues.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Queue deleted successfully'),
                    backgroundColor: Color(0xFFE8B4B7),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class QueueItem {
  final String name;
  final String peopleCount;
  final IconData icon;

  QueueItem({
    required this.name,
    required this.peopleCount,
    required this.icon,
  });
}
import 'package:flutter/material.dart';
import 'services/merchant_queue_service.dart';
import 'models/merchant_queue.dart';
import 'components/queue_card.dart';
import 'components/create_queue_dialog.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<MerchantQueue> _queues = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQueues();
  }

  Future<void> _loadQueues() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final queues = await MerchantQueueService.getMerchantQueues();
      setState(() {
        _queues = queues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showCreateQueueDialog() async {
    await showDialog(
      context: context,
      builder: (context) => CreateQueueDialog(
        onCreateQueue: _handleCreateQueue,
      ),
    );
  }

  Future<void> _handleCreateQueue({
    required String name,
    required int maxSize,
    required double inQoinRate,
    required int alertNumber,
    required int bufferNumber,
  }) async {
    try {
      await MerchantQueueService.createQueue(
        name: name,
        maxSize: maxSize,
        inQoinRate: inQoinRate,
        alertNumber: alertNumber,
        bufferNumber: bufferNumber,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Queue created successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      _loadQueues(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    }
  }

  Future<void> _handleProcessNext(MerchantQueue queue) async {
    try {
      await MerchantQueueService.processNextCustomer(queue.qid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer processed successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      _loadQueues(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handlePauseQueue(MerchantQueue queue) async {
    try {
      await MerchantQueueService.pauseQueue(queue.qid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Queue paused successfully'),
          backgroundColor: Color(0xFFFF9800),
        ),
      );
      _loadQueues(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleResumeQueue(MerchantQueue queue) async {
    try {
      await MerchantQueueService.resumeQueue(queue.qid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Queue resumed successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      _loadQueues(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleStopQueue(MerchantQueue queue) async {
    try {
      await MerchantQueueService.stopQueue(queue.qid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Queue stopped successfully'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      _loadQueues(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToQueueDetails(MerchantQueue queue) {
    Navigator.pushNamed(
      context,
      '/queue-management',
      arguments: queue,
    );
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
                  const Expanded(
                    child: Text(
                      'Queue Management',
                      style: TextStyle(
                        color: Color(0xFF191010),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _showCreateQueueDialog,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stats Summary
            if (_queues.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.queue,
                      label: 'Total Queues',
                      value: _queues.length.toString(),
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      icon: Icons.play_circle_filled,
                      label: 'Active',
                      value: _queues.where((q) => q.isActive).length.toString(),
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      icon: Icons.people,
                      label: 'Total Customers',
                      value:
                          _queues.fold(0, (sum, q) => sum + q.size).toString(),
                    ),
                  ],
                ),
              ),
            ],

            // Queue List Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  const Text(
                    'Your Queues',
                    style: TextStyle(
                      color: Color(0xFF191010),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.015,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _loadQueues,
                    icon: const Icon(
                      Icons.refresh,
                      color: Color(0xFF8B5B5C),
                    ),
                  ),
                ],
              ),
            ),

            // Queue List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF4CAF50)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading queues...',
                            style: TextStyle(
                              color: Color(0xFF8B5B5C),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Color(0xFFF44336),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading queues',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B0E0E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFF8B5B5C),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadQueues,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _queues.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                    child: const Icon(
                                      Icons.queue,
                                      size: 60,
                                      color: Color(0xFF8B5B5C),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'No queues yet',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B0E0E),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Create your first queue to start managing customers',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8B5B5C),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _showCreateQueueDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create Queue'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadQueues,
                              color: const Color(0xFF4CAF50),
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _queues.length,
                                itemBuilder: (context, index) {
                                  final queue = _queues[index];
                                  return QueueCard(
                                    queue: queue,
                                    onTap: () => _navigateToQueueDetails(queue),
                                    onProcessNext: () =>
                                        _handleProcessNext(queue),
                                    onPause: () => _handlePauseQueue(queue),
                                    onResume: () => _handleResumeQueue(queue),
                                    onStop: () => _handleStopQueue(queue),
                                  );
                                },
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
              icon: Icon(Icons.queue),
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

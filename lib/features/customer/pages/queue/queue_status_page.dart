import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/api_endpoints.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';

class QueueStatusPage extends StatefulWidget {
  const QueueStatusPage({super.key});

  @override
  State<QueueStatusPage> createState() => _QueueStatusPageState();
}

class _QueueStatusPageState extends State<QueueStatusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _currentQueues = [];
  List<Map<String, dynamic>> _pastQueues = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchQueueData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchQueueData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null) {
        setState(() {
          _error = 'Authentication token not found';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/customer/summary'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> customerQueues =
              jsonResponse['data']['customerQueues'];
          setState(() {
            _currentQueues = customerQueues
                .where((queue) =>
                    queue['status'] != 'completed' &&
                    queue['status'] != 'cancelled')
                .map((queue) => Map<String, dynamic>.from(queue))
                .toList();
            _pastQueues = customerQueues
                .where((queue) =>
                    queue['status'] == 'completed' ||
                    queue['status'] == 'cancelled')
                .map((queue) => Map<String, dynamic>.from(queue))
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = jsonResponse['message'] ?? 'Failed to fetch queue data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to fetch queue data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Queue Status',
          style: CommonStyle.heading2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Current'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: CommonStyle.errorTextStyle,
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQueueList(_currentQueues, true),
                    _buildQueueList(_pastQueues, false),
                  ],
                ),
    );
  }

  Widget _buildQueueList(List<Map<String, dynamic>> queues, bool isCurrent) {
    if (queues.isEmpty) {
      return Center(
        child: Text(
          isCurrent ? 'No active queues' : 'No past queues',
          style: CommonStyle.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: queues.length,
      itemBuilder: (context, index) {
        final queue = queues[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: AppColors.backgroundLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        queue['queueName'] ?? 'Unknown Queue',
                        style: CommonStyle.heading3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(queue['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusText(queue['status']),
                        style: CommonStyle.caption.copyWith(
                          color: _getStatusColor(queue['status']),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Store',
                  queue['storeName'] ?? 'Unknown Store',
                ),
                if (isCurrent) ...[
                  _buildDetailRow(
                    'Current Position',
                    '${queue['currentRank']?.toString() ?? '0'} of ${queue['currentQueueSize']?.toString() ?? '0'}',
                  ),
                ],
                _buildDetailRow(
                  'Joined Position',
                  '${queue['joinedPosition']?.toString() ?? '0'}',
                ),
                if (queue['comment'] != null)
                  _buildDetailRow(
                    'Comment',
                    queue['comment'],
                  ),
                if ((queue['inQoinCharged'] ?? 0) > 0)
                  _buildDetailRow(
                    'inQoin Charged',
                    '${queue['inQoinCharged']?.toString() ?? '0'}',
                  ),
                _buildDetailRow(
                  'Processed',
                  '${queue['processed']?.toString() ?? '0'}',
                ),
                if (!isCurrent)
                  _buildDetailRow(
                    'Completed At',
                    _formatDate(queue['timestamp']),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: CommonStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: CommonStyle.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Waiting';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'processing':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}

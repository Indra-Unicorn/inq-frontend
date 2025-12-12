import 'package:flutter/material.dart';
import '../models/merchant_queue.dart';
import '../models/queue_history_entry.dart';
import '../services/merchant_queue_service.dart';
import '../../../shared/constants/app_colors.dart';

class QueueHistoryPage extends StatefulWidget {
  final List<MerchantQueue> queues;

  const QueueHistoryPage({
    super.key,
    required this.queues,
  });

  @override
  State<QueueHistoryPage> createState() => _QueueHistoryPageState();
}

class _QueueHistoryPageState extends State<QueueHistoryPage> {
  List<QueueHistoryEntry> _allHistory = [];
  List<QueueHistoryEntry> _filteredHistory = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedQueueId;
  Map<String, List<QueueHistoryEntry>> _historyByQueue = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allHistoryEntries = <QueueHistoryEntry>[];

      // Load history for all queues
      for (final queue in widget.queues) {
        try {
          final history = await MerchantQueueService.getQueueHistory(queue.qid);
          allHistoryEntries.addAll(history);
          _historyByQueue[queue.qid] = history;
        } catch (e) {
          // Continue loading other queues even if one fails
        }
      }

      // Sort by joined time (most recent first)
      allHistoryEntries.sort((a, b) {
        final aTime = a.joinedDateTime ?? DateTime(1970);
        final bTime = b.joinedDateTime ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      setState(() {
        _allHistory = allHistoryEntries;
        _filteredHistory = allHistoryEntries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterByQueue(String? queueId) {
    setState(() {
      _selectedQueueId = queueId;
      if (queueId == null) {
        _filteredHistory = _allHistory;
      } else {
        _filteredHistory = _historyByQueue[queueId] ?? [];
        // Sort by joined time
        _filteredHistory.sort((a, b) {
          final aTime = a.joinedDateTime ?? DateTime(1970);
          final bTime = b.joinedDateTime ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Queue History',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Queue Filter
            if (widget.queues.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedQueueId,
                        isExpanded: true,
                        hint: const Text('All Queues'),
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Queues'),
                          ),
                          ...widget.queues.map((queue) {
                            return DropdownMenuItem<String>(
                              value: queue.qid,
                              child: Text(queue.name),
                            );
                          }),
                        ],
                        onChanged: _filterByQueue,
                      ),
                    ),
                  ],
                ),
              ),
            // History List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
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
                                'Error loading history',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadHistory,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredHistory.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.history,
                                    size: 64,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No history found',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Customer history will appear here',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadHistory,
                              color: AppColors.primary,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredHistory.length,
                                itemBuilder: (context, index) {
                                  final entry = _filteredHistory[index];
                                  return _buildHistoryCard(entry, theme);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(QueueHistoryEntry entry, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Customer Name
              Expanded(
                child: Text(
                  entry.customerName ?? 'Unknown Customer',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: entry.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: entry.statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  entry.statusDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: entry.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Details Grid
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.queue,
                  'Position',
                  '${entry.joinedPosition}',
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.access_time,
                  'Joined',
                  entry.joinedDateDisplay,
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.monetization_on,
                  'InQoin',
                  entry.inQoinCharged.toStringAsFixed(1),
                  const Color(0xFF9C27B0),
                ),
              ),
              if (entry.queueName != null)
                Expanded(
                  child: _buildDetailItem(
                    Icons.list_alt,
                    'Queue',
                    entry.queueName!,
                    AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


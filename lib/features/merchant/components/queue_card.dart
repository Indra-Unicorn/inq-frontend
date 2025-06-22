import 'package:flutter/material.dart';
import '../models/merchant_queue.dart';

class QueueCard extends StatelessWidget {
  final MerchantQueue queue;
  final VoidCallback? onTap;
  final VoidCallback? onProcessNext;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onStop;

  const QueueCard({
    super.key,
    required this.queue,
    this.onTap,
    this.onProcessNext,
    this.onPause,
    this.onResume,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Queue Icon and Status
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            queue.statusColor.withOpacity(0.1),
                            queue.statusColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getQueueIcon(),
                        color: queue.statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Queue Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            queue.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B0E0E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: queue.statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  queue.statusDisplay,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: queue.statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                queue.timeSinceUpdate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8B5B5C),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Capacity Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getCapacityColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${queue.size}/${queue.maxSize}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getCapacityColor(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.people,
                      label: 'In Queue',
                      value: queue.size.toString(),
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      icon: Icons.check_circle,
                      label: 'Processed',
                      value: queue.processed.toString(),
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      icon: Icons.speed,
                      label: 'Rate',
                      value: queue.processingRateDisplay,
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      icon: Icons.monetization_on,
                      label: 'InQoin',
                      value: queue.inQoinRate.toString(),
                      color: const Color(0xFF9C27B0),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress Bar
                if (queue.maxSize > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: queue.capacityPercentage / 100,
                            backgroundColor: const Color(0xFFF0F0F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getCapacityColor(),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${queue.capacityPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getCapacityColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                if (queue.isActive) ...[
                  // Process Next Button - More Prominent
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: queue.size > 0 ? onProcessNext : null,
                      icon: Icon(
                        Icons.play_arrow,
                        size: 24,
                        color: queue.size > 0 ? Colors.white : Colors.grey[400],
                      ),
                      label: Text(
                        queue.size > 0
                            ? 'Process Next Customer'
                            : 'No Customers in Queue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              queue.size > 0 ? Colors.white : Colors.grey[400],
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: queue.size > 0
                            ? const Color(0xFF4CAF50)
                            : Colors.grey[300],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: queue.size > 0 ? 4 : 0,
                        shadowColor: queue.size > 0
                            ? const Color(0xFF4CAF50).withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Secondary Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onPause,
                          icon: const Icon(Icons.pause, size: 18),
                          label: const Text('Pause'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onStop,
                          icon: const Icon(Icons.stop, size: 18),
                          label: const Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF44336),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (queue.isPaused) ...[
                  // Resume Button - More Prominent
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onResume,
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text(
                        'Resume Queue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF4CAF50).withOpacity(0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stop Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onStop,
                      icon: const Icon(Icons.stop, size: 20),
                      label: const Text('Stop Queue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF8B5B5C),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getQueueIcon() {
    if (queue.isActive) return Icons.play_circle_filled;
    if (queue.isPaused) return Icons.pause_circle_filled;
    if (queue.isStopped) return Icons.stop_circle;
    return Icons.queue;
  }

  Color _getCapacityColor() {
    if (queue.isAtCapacity) return const Color(0xFFF44336);
    if (queue.isNearCapacity) return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }
}

import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';

class CloseQueueConfirmationDialog extends StatelessWidget {
  final String queueName;
  final int currentCustomers;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CloseQueueConfirmationDialog({
    super.key,
    required this.queueName,
    required this.currentCustomers,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFFFF9800),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Close Queue?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B0E0E),
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to close "$queueName".',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B0E0E),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFE69C),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF856404),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Impact Warning',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF856404),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentCustomers > 0
                      ? '• All $currentCustomers customers will be removed from the queue immediately'
                      : '• The queue will be closed immediately',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF856404),
                  ),
                ),
                const Text(
                  '• Customers will lose their position and need to rejoin when you reopen',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF856404),
                  ),
                ),
                const Text(
                  '• You can reopen the queue later by resuming it',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF856404),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Are you sure you want to proceed?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF44336),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Close Queue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

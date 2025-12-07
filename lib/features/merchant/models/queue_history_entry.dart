import 'package:flutter/material.dart';

class QueueHistoryEntry {
  final String id;
  final String customerId;
  final String? queueName;
  final int joinedPosition;
  final int lastPosition;
  final int waitTime;
  final double inQoinCharged;
  final String? joinComment;
  final String? leaveReason;
  final bool wasProcessed;
  final String queueCompletionStatus;
  final String? createdAt;
  final String? joinedTime;
  final String? customerName;
  final String? customerPhoneNumber;
  final String qid;

  QueueHistoryEntry({
    required this.id,
    required this.customerId,
    this.queueName,
    required this.joinedPosition,
    required this.lastPosition,
    required this.waitTime,
    required this.inQoinCharged,
    this.joinComment,
    this.leaveReason,
    required this.wasProcessed,
    required this.queueCompletionStatus,
    this.createdAt,
    this.joinedTime,
    this.customerName,
    this.customerPhoneNumber,
    required this.qid,
  });

  factory QueueHistoryEntry.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is double) return value.toInt();
      if (value is String) {
        if (value == "Infinity" || value == "infinity") return 999999;
        return int.tryParse(value) ?? 0;
      }
      return value as int;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return value as double;
    }

    return QueueHistoryEntry(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      queueName: json['queueName'],
      joinedPosition: parseInt(json['joinedPosition']),
      lastPosition: parseInt(json['lastPosition']),
      waitTime: parseInt(json['waitTime']),
      inQoinCharged: parseDouble(json['inQoinCharged']),
      joinComment: json['joinComment'],
      leaveReason: json['leaveReason'],
      wasProcessed: json['wasProcessed'] ?? false,
      queueCompletionStatus: json['queueCompletionStatus'] ?? 'UNKNOWN',
      createdAt: json['createdAt'],
      joinedTime: json['joinedAt'] ?? json['joinedTime'],
      customerName: json['customerName'],
      customerPhoneNumber: json['customerPhoneNumber'],
      qid: json['qid'] ?? '',
    );
  }

  DateTime? get joinedDateTime {
    if (joinedTime == null) return null;
    return DateTime.tryParse(joinedTime!);
  }

  String get joinedDateDisplay {
    final date = joinedDateTime;
    if (date == null) return 'Unknown';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);
    
    if (entryDate == today) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (entryDate == yesterday) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  String get statusDisplay {
    switch (queueCompletionStatus) {
      case 'COMPLETED':
        return 'Completed';
      case 'REMOVED':
        return 'Removed';
      case 'LEFT':
        return 'Left';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (queueCompletionStatus) {
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'REMOVED':
        return const Color(0xFFFF9800);
      case 'LEFT':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}


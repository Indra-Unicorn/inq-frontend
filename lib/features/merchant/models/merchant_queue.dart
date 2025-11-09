import 'package:flutter/material.dart';

class MerchantQueue {
  final String shopId;
  final String status;
  final String name;
  final int size;
  final int maxSize;
  final int processed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double inQoinRate;
  final int alertNumber;
  final int bufferNumber;
  final bool hasCapacity;
  final double processingRate;
  final bool full;
  final String qid;

  MerchantQueue({
    required this.shopId,
    required this.status,
    required this.name,
    required this.size,
    required this.maxSize,
    required this.processed,
    required this.createdAt,
    required this.updatedAt,
    required this.inQoinRate,
    required this.alertNumber,
    required this.bufferNumber,
    required this.hasCapacity,
    required this.processingRate,
    required this.full,
    required this.qid,
  });

  factory MerchantQueue.fromJson(Map<String, dynamic> json) {
    return MerchantQueue(
      shopId: json['shopId'] ?? '',
      status: json['status'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      maxSize: json['maxSize'] ?? 0,
      processed: json['processed'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      inQoinRate: (json['inQoinRate'] ?? 0.0).toDouble(),
      alertNumber: json['alertNumber'] ?? 0,
      bufferNumber: json['bufferNumber'] ?? 0,
      hasCapacity: json['hasCapacity'] ?? false,
      processingRate: _parseProcessingRate(json['processingRate']),
      full: json['full'] ?? false,
      qid: json['qid'] ?? '',
    );
  }

  static double _parseProcessingRate(dynamic rate) {
    if (rate == null) return 0.0;
    if (rate == 'Infinity') return double.infinity;
    if (rate is int) return rate.toDouble();
    if (rate is double) return rate;
    if (rate is String) {
      if (rate == 'Infinity') return double.infinity;
      return double.tryParse(rate) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'status': status,
      'name': name,
      'size': size,
      'maxSize': maxSize,
      'processed': processed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'inQoinRate': inQoinRate,
      'alertNumber': alertNumber,
      'bufferNumber': bufferNumber,
      'hasCapacity': hasCapacity,
      'processingRate':
          processingRate == double.infinity ? 'Infinity' : processingRate,
      'full': full,
      'qid': qid,
    };
  }

  // Computed properties
  bool get isActive => status == 'ACTIVE';
  bool get isPaused => status == 'PAUSED';
  bool get isStopped => status == 'STOPPED' || status == 'CLOSED';
  bool get isClosed => status == 'CLOSED';

  double get capacityPercentage => maxSize > 0 ? (size / maxSize) * 100 : 0;
  bool get isNearCapacity => capacityPercentage >= 80;
  bool get isAtCapacity => capacityPercentage >= 100;

  String get processingRateDisplay {
    if (processingRate == double.infinity) return '∞';
    if (processingRate == 0) return '0';
    return processingRate.toStringAsFixed(1);
  }

  String get statusDisplay {
    switch (status) {
      case 'ACTIVE':
        return 'Active';
      case 'PAUSED':
        return 'Paused';
      case 'STOPPED':
        return 'Stopped';
      case 'CLOSED':
        return 'Closed';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFF4CAF50);
      case 'PAUSED':
        return const Color(0xFFFF9800);
      case 'STOPPED':
      case 'CLOSED':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String get timeSinceUpdate {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

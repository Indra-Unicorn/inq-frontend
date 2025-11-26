import 'package:flutter/material.dart';

class Shop {
  final String shopId;
  final String shopName;
  final String? shopPhoneNumber;
  final ShopAddress address;
  final bool isOpen;
  final String? openTime;
  final String? closeTime;
  final double rating;
  final int ratingCount;
  final List<String> categories;
  final List<String> images;
  final Map<String, dynamic> metadata;
  final List<QueueResponse>? queueResponses;

  Shop({
    required this.shopId,
    required this.shopName,
    this.shopPhoneNumber,
    required this.address,
    required this.isOpen,
    this.openTime,
    this.closeTime,
    required this.rating,
    required this.ratingCount,
    required this.categories,
    required this.images,
    required this.metadata,
    this.queueResponses,
  });

  // Calculate shop status based on queue statuses
  String get shopStatus {
    if (queueResponses == null || queueResponses!.isEmpty) {
      return 'CLOSED';
    }

    bool hasActive = false;
    bool hasPaused = false;
    bool hasStopped = false;

    for (final queue in queueResponses!) {
      switch (queue.status.toUpperCase()) {
        case 'ACTIVE':
          hasActive = true;
          break;
        case 'PAUSED':
          hasPaused = true;
          break;
        case 'STOPPED':
        case 'CLOSED':
          hasStopped = true;
          break;
      }
    }

    // If any queue is active, shop is active
    if (hasActive) return 'ACTIVE';
    
    // If any queue is paused and rest are stopped, shop is paused
    if (hasPaused && !hasActive) return 'PAUSED';
    
    // If all queues are stopped, shop is closed
    return 'CLOSED';
  }

  // Get status color based on shop status
  Color get statusColor {
    switch (shopStatus) {
      case 'ACTIVE':
        return const Color(0xFF4CAF50); // Green
      case 'PAUSED':
        return const Color(0xFFFF9800); // Orange
      case 'CLOSED':
      default:
        return const Color(0xFFF44336); // Red
    }
  }

  // Calculate minimum average time per customer from all queues (in minutes)
  int get avgEntryTimeMinutes {
    if (queueResponses == null || queueResponses!.isEmpty) {
      return 0;
    }

    int? minTime;
    for (final queue in queueResponses!) {
      if (queue.avgTimePerCustomer != null) {
        try {
          final timeInMinutes = int.parse(queue.avgTimePerCustomer!);
          if (timeInMinutes > 0) {
            if (minTime == null || timeInMinutes < minTime) {
              minTime = timeInMinutes;
            }
          }
        } catch (e) {
          // Skip invalid values
          continue;
        }
      }
    }
    
    return minTime ?? 0;
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shopId: json['shopId'],
      shopName: json['shopName'],
      shopPhoneNumber: json['shopPhoneNumber'],
      address: json['address'] != null
          ? ShopAddress.fromJson(json['address'])
          : ShopAddress(
              streetAddress: '',
              postalCode: '',
              location: '',
              city: '',
              state: '',
              country: '',
            ),
      isOpen: json['isOpen'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      metadata: json['metadata'] ?? {},
      queueResponses: json['queueResponses'] != null
          ? List<QueueResponse>.from(
              json['queueResponses'].map((x) => QueueResponse.fromJson(x)))
          : null,
    );
  }
}

class ShopAddress {
  final String streetAddress;
  final String postalCode;
  final String location;
  final String city;
  final String state;
  final String country;

  ShopAddress({
    required this.streetAddress,
    required this.postalCode,
    required this.location,
    required this.city,
    required this.state,
    required this.country,
  });

  factory ShopAddress.fromJson(Map<String, dynamic> json) {
    return ShopAddress(
      streetAddress: json['streetAddress'] ?? '',
      postalCode: json['postalCode'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class QueueResponse {
  final String shopId;
  final String status;
  final String name;
  final int size;
  final int maxSize;
  final int processed;
  final String createdAt;
  final String updatedAt;
  final double inQoinRate;
  final int alertNumber;
  final int bufferNumber;
  final String? avgTimePerCustomer;
  final bool hasCapacity;
  final bool full;
  final String qid;

  QueueResponse({
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
    this.avgTimePerCustomer,
    required this.hasCapacity,
    required this.full,
    required this.qid,
  });

  factory QueueResponse.fromJson(Map<String, dynamic> json) {
    // Handle avgTimePerCustomer which can be int, double, or string
    String? avgTime;
    final avgTimeValue = json['avgTimePerCustomer'];
    if (avgTimeValue != null) {
      avgTime = avgTimeValue.toString();
    }

    return QueueResponse(
      shopId: json['shopId'] ?? '',
      status: json['status'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      maxSize: json['maxSize'] ?? 0,
      processed: json['processed'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      inQoinRate: (json['inQoinRate'] ?? 0.0).toDouble(),
      alertNumber: json['alertNumber'] ?? 0,
      bufferNumber: json['bufferNumber'] ?? 0,
      avgTimePerCustomer: avgTime,
      hasCapacity: json['hasCapacity'] ?? false,
      full: json['full'] ?? false,
      qid: json['qid'] ?? '',
    );
  }
}

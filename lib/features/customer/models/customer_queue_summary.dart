import 'package:flutter/material.dart';

class CustomerQueueSummary {
  final List<CustomerQueue> customerQueues;
  final List<CustomerPastQueue> customerPastQueues;

  CustomerQueueSummary({
    required this.customerQueues,
    required this.customerPastQueues,
  });

  factory CustomerQueueSummary.fromJson(Map<String, dynamic> json) {
    return CustomerQueueSummary(
      customerQueues: (json['customerQueues'] as List)
          .map((queue) => CustomerQueue.fromJson(queue))
          .toList(),
      customerPastQueues: (json['customerPastQueues'] as List)
          .map((queue) => CustomerPastQueue.fromJson(queue))
          .toList(),
    );
  }
}

class CustomerQueue {
  final String id;
  final String customerId;
  final String? queueName;
  final int positionOffset;
  final int joinedPosition;
  final int currentRank;
  final double inQoinCharged;
  final int currentQueueSize;
  final int processed;
  final int? estimatedWaitTime;
  final String? comment;
  final String? createdAt;
  final String? updatedAt;
  final String? joinedTime;
  final String? customerName;
  final String? customerPhoneNumber;
  final String qid;
  final ShopResponse shopResponse;

  CustomerQueue({
    required this.id,
    required this.customerId,
    this.queueName,
    required this.positionOffset,
    required this.joinedPosition,
    required this.currentRank,
    required this.inQoinCharged,
    required this.currentQueueSize,
    required this.processed,
    this.estimatedWaitTime,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.joinedTime,
    this.customerName,
    this.customerPhoneNumber,
    required this.qid,
    required this.shopResponse,
  });

  factory CustomerQueue.fromJson(Map<String, dynamic> json) {
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

    return CustomerQueue(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      queueName: json['queueName'],
      positionOffset: parseInt(json['positionOffset']),
      joinedPosition: parseInt(json['joinedPosition']),
      currentRank: parseInt(json['currentRank']),
      inQoinCharged: parseDouble(json['inQoinCharged']),
      currentQueueSize: parseInt(json['currentQueueSize']),
      processed: parseInt(json['processed']),
      estimatedWaitTime: parseInt(json['estimatedWaitTime']),
      comment: json['comment'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      joinedTime: json['joinedAt'] ?? json['joinedTime'],
      customerName: json['customerName'],
      customerPhoneNumber: json['customerPhoneNumber'],
      qid: json['qid'] ?? '',
      shopResponse: ShopResponse.fromJson(json['shopResponse'] ?? {}),
    );
  }

  String get estimatedWaitTimeDisplay {
    if (estimatedWaitTime == null) return 'Calculating...';
    if (estimatedWaitTime == 0) return 'Ready';
    return '$estimatedWaitTime min';
  }
}

class CustomerPastQueue {
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
  final String? createdAt;
  final String? joinedTime;
  final String? customerName;
  final String? customerPhoneNumber;
  final String qid;
  final ShopResponse shopResponse;

  CustomerPastQueue({
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
    this.createdAt,
    this.joinedTime,
    this.customerName,
    this.customerPhoneNumber,
    required this.qid,
    required this.shopResponse,
  });

  factory CustomerPastQueue.fromJson(Map<String, dynamic> json) {
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

    return CustomerPastQueue(
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
      createdAt: json['createdAt'],
      joinedTime: json['joinedAt'] ?? json['joinedTime'],
      customerName: json['customerName'],
      customerPhoneNumber: json['customerPhoneNumber'],
      qid: json['qid'] ?? '',
      shopResponse: ShopResponse.fromJson(json['shopResponse'] ?? {}),
    );
  }

  String get waitTimeDisplay {
    if (waitTime < 60) return '$waitTime min';
    final hours = waitTime ~/ 60;
    final minutes = waitTime % 60;
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  String get statusDisplay {
    if (wasProcessed) return 'Completed';
    if (leaveReason != null) return 'Left Queue';
    return 'Unknown';
  }

  Color get statusColor {
    if (wasProcessed) return const Color(0xFF4CAF50);
    if (leaveReason != null) return const Color(0xFFFF9800);
    return const Color(0xFF9E9E9E);
  }
}

class ShopResponse {
  final String shopId;
  final String shopName;
  final String shopPhoneNumber;
  final ShopAddress address;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final double rating;
  final int ratingCount;
  final List<String> categories;
  final List<String> images;
  final Map<String, dynamic> metadata;

  ShopResponse({
    required this.shopId,
    required this.shopName,
    required this.shopPhoneNumber,
    required this.address,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.rating,
    required this.ratingCount,
    required this.categories,
    required this.images,
    required this.metadata,
  });

  factory ShopResponse.fromJson(Map<String, dynamic> json) {
    return ShopResponse(
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      shopPhoneNumber: json['shopPhoneNumber'] ?? '',
      address: ShopAddress.fromJson(json['address'] ?? {}),
      isOpen: json['isOpen'] ?? false,
      openTime: json['openTime'] ?? '09:00:00',
      closeTime: json['closeTime'] ?? '17:00:00',
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }

  String get fullAddress {
    return '${address.streetAddress}, ${address.city}, ${address.state} ${address.postalCode}, ${address.country}';
  }

  String get ratingDisplay {
    if (ratingCount == 0) return 'No ratings yet';
    return '${rating.toStringAsFixed(1)} ($ratingCount reviews)';
  }

  String get categoriesDisplay {
    return categories.join(', ');
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

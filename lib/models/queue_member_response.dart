class QueueMemberResponse {
  final String? id;
  final String? customerId;
  final String? qId;
  final String? queueName;
  final int positionOffset;
  final int joinedPosition;
  final int currentRank;
  final double inQoinCharged;
  final int currentQueueSize;
  final int processed;
  final int? estimatedWaitTime;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? customerName;
  final String? customerPhoneNumber;
  final String? status;
  final String? message;
  final String? timestamp;

  QueueMemberResponse({
    this.id,
    this.customerId,
    this.qId,
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
    this.customerName,
    this.customerPhoneNumber,
    this.status,
    this.message,
    this.timestamp,
  });

  factory QueueMemberResponse.fromJson(Map<String, dynamic> json) {
    return QueueMemberResponse(
      id: json['id'],
      customerId: json['customerId'],
      qId: json['qid'],
      queueName: json['queueName'],
      positionOffset: _parseInt(json['positionOffset']),
      joinedPosition: _parseInt(json['joinedPosition']),
      currentRank: _parseInt(json['currentRank']),
      inQoinCharged: _parseDouble(json['inQoinCharged']),
      currentQueueSize: _parseInt(json['currentQueueSize']),
      processed: _parseInt(json['processed']),
      estimatedWaitTime: _parseInt(json['estimatedWaitTime']),
      comment: json['comment'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      customerName: json['customerName'],
      customerPhoneNumber: json['customerPhoneNumber'],
      status: json['status'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'qId': qId,
      'queueName': queueName,
      'positionOffset': positionOffset,
      'joinedPosition': joinedPosition,
      'currentRank': currentRank,
      'inQoinCharged': inQoinCharged,
      'currentQueueSize': currentQueueSize,
      'processed': processed,
      'estimatedWaitTime': estimatedWaitTime,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'customerName': customerName,
      'customerPhoneNumber': customerPhoneNumber,
      'status': status,
      'message': message,
      'timestamp': timestamp,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value.toInt();
    if (value is String) {
      if (value == "Infinity" || value == "infinity") return 999999;
      return int.tryParse(value) ?? 0;
    }
    return value as int;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return value as double;
  }

  bool get isCompleted => status == 'completed' || processed > 0;

  @override
  String toString() {
    return 'QueueMemberResponse(id: $id, queueName: $queueName, currentRank: $currentRank, currentQueueSize: $currentQueueSize)';
  }
} 
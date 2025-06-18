class CustomerQueueSummary {
  final List<CustomerQueue> customerQueues;
  final List<CustomerQueue> customerPastQueues;

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
          .map((queue) => CustomerQueue.fromJson(queue))
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
  final int inQoinCharged;
  final int currentQueueSize;
  final int processed;
  final String? estimatedWaitTime;
  final String? comment;
  final String? createdAt;
  final String? updatedAt;
  final String? customerName;
  final String? customerPhoneNumber;
  final String qid;

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
    this.customerName,
    this.customerPhoneNumber,
    required this.qid,
  });

  factory CustomerQueue.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is double) return value.toInt();
      if (value is String) {
        if (value == "Infinity" || value == "infinity") return 999999;
        return int.tryParse(value) ?? 0;
      }
      return value as int;
    }

    return CustomerQueue(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      queueName: json['queueName'],
      positionOffset: _parseInt(json['positionOffset']),
      joinedPosition: _parseInt(json['joinedPosition']),
      currentRank: _parseInt(json['currentRank']),
      inQoinCharged: _parseInt(json['inQoinCharged']),
      currentQueueSize: _parseInt(json['currentQueueSize']),
      processed: _parseInt(json['processed']),
      estimatedWaitTime: json['estimatedWaitTime'],
      comment: json['comment'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      customerName: json['customerName'],
      customerPhoneNumber: json['customerPhoneNumber'],
      qid: json['qid'] ?? '',
    );
  }
} 
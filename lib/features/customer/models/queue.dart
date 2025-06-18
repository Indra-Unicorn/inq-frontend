class Queue {
  final String qid;
  final String shopId;
  final String status;
  final String name;
  final int size;
  final int maxSize;
  final int processed;
  final String createdAt;
  final String updatedAt;
  final int inQoinRate;
  final int alertNumber;
  final int bufferNumber;
  final bool hasCapacity;
  final int processingRate;
  final bool full;

  Queue({
    required this.qid,
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
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value) {
      if (value == "Infinity" || value == "infinity") {
        return 999999; // Use a large number to represent infinity
      }
      if (value is double) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return value as int;
    }

    return Queue(
      qid: json['qid'],
      shopId: json['shopId'],
      status: json['status'],
      name: json['name'],
      size: _parseInt(json['size']),
      maxSize: _parseInt(json['maxSize']),
      processed: _parseInt(json['processed']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      inQoinRate: _parseInt(json['inQoinRate']),
      alertNumber: _parseInt(json['alertNumber']),
      bufferNumber: _parseInt(json['bufferNumber']),
      hasCapacity: json['hasCapacity'],
      processingRate: _parseInt(json['processingRate']),
      full: json['full'],
    );
  }
} 
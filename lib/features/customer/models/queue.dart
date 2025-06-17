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
    return Queue(
      qid: json['qid'],
      shopId: json['shopId'],
      status: json['status'],
      name: json['name'],
      size: (json['size'] is double) ? (json['size'] as double).toInt() : json['size'],
      maxSize: (json['maxSize'] is double) ? (json['maxSize'] as double).toInt() : json['maxSize'],
      processed: (json['processed'] is double) ? (json['processed'] as double).toInt() : json['processed'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      inQoinRate: (json['inQoinRate'] is double) ? (json['inQoinRate'] as double).toInt() : json['inQoinRate'],
      alertNumber: (json['alertNumber'] is double) ? (json['alertNumber'] as double).toInt() : json['alertNumber'],
      bufferNumber: (json['bufferNumber'] is double) ? (json['bufferNumber'] as double).toInt() : json['bufferNumber'],
      hasCapacity: json['hasCapacity'],
      processingRate: (json['processingRate'] is double) ? (json['processingRate'] as double).toInt() : json['processingRate'],
      full: json['full'],
    );
  }
} 
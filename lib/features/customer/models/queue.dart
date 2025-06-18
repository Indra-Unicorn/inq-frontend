import 'queue_status.dart';
import 'queue_parser.dart';
import 'queue_validator.dart';

class Queue {
  final String qid;
  final String shopId;
  final QueueStatus status;
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

  Queue._({
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
    final size = QueueParser.parseInt(json['size']);
    final maxSize = QueueParser.parseInt(json['maxSize']);
    final processed = QueueParser.parseInt(json['processed']);
    final inQoinRate = QueueParser.parseInt(json['inQoinRate']);
    final alertNumber = QueueParser.parseInt(json['alertNumber']);
    final bufferNumber = QueueParser.parseInt(json['bufferNumber']);
    final processingRate = QueueParser.parseInt(json['processingRate']);

    if (!QueueValidator.validateQueueData(
      size: size,
      maxSize: maxSize,
      processed: processed,
      inQoinRate: inQoinRate,
      alertNumber: alertNumber,
      bufferNumber: bufferNumber,
      processingRate: processingRate,
    )) {
      throw FormatException('Invalid queue data');
    }

    return Queue._(
      qid: QueueParser.parseString(json['qid']),
      shopId: QueueParser.parseString(json['shopId']),
      status: QueueStatus.fromString(QueueParser.parseString(json['status'])),
      name: QueueParser.parseString(json['name']),
      size: size,
      maxSize: maxSize,
      processed: processed,
      createdAt: QueueParser.parseString(json['createdAt']),
      updatedAt: QueueParser.parseString(json['updatedAt']),
      inQoinRate: inQoinRate,
      alertNumber: alertNumber,
      bufferNumber: bufferNumber,
      hasCapacity: QueueParser.parseBoolean(json['hasCapacity']),
      processingRate: processingRate,
      full: QueueParser.parseBoolean(json['full']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qid': qid,
      'shopId': shopId,
      'status': status.value,
      'name': name,
      'size': size,
      'maxSize': maxSize,
      'processed': processed,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'inQoinRate': inQoinRate,
      'alertNumber': alertNumber,
      'bufferNumber': bufferNumber,
      'hasCapacity': hasCapacity,
      'processingRate': processingRate,
      'full': full,
    };
  }

  Queue copyWith({
    String? qid,
    String? shopId,
    QueueStatus? status,
    String? name,
    int? size,
    int? maxSize,
    int? processed,
    String? createdAt,
    String? updatedAt,
    int? inQoinRate,
    int? alertNumber,
    int? bufferNumber,
    bool? hasCapacity,
    int? processingRate,
    bool? full,
  }) {
    return Queue._(
      qid: qid ?? this.qid,
      shopId: shopId ?? this.shopId,
      status: status ?? this.status,
      name: name ?? this.name,
      size: size ?? this.size,
      maxSize: maxSize ?? this.maxSize,
      processed: processed ?? this.processed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      inQoinRate: inQoinRate ?? this.inQoinRate,
      alertNumber: alertNumber ?? this.alertNumber,
      bufferNumber: bufferNumber ?? this.bufferNumber,
      hasCapacity: hasCapacity ?? this.hasCapacity,
      processingRate: processingRate ?? this.processingRate,
      full: full ?? this.full,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Queue &&
          runtimeType == other.runtimeType &&
          qid == other.qid &&
          shopId == other.shopId &&
          status == other.status &&
          name == other.name &&
          size == other.size &&
          maxSize == other.maxSize &&
          processed == other.processed &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          inQoinRate == other.inQoinRate &&
          alertNumber == other.alertNumber &&
          bufferNumber == other.bufferNumber &&
          hasCapacity == other.hasCapacity &&
          processingRate == other.processingRate &&
          full == other.full;

  @override
  int get hashCode =>
      qid.hashCode ^
      shopId.hashCode ^
      status.hashCode ^
      name.hashCode ^
      size.hashCode ^
      maxSize.hashCode ^
      processed.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      inQoinRate.hashCode ^
      alertNumber.hashCode ^
      bufferNumber.hashCode ^
      hasCapacity.hashCode ^
      processingRate.hashCode ^
      full.hashCode;
}

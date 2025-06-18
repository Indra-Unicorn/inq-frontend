enum QueueStatus {
  active,
  paused,
  closed,
  completed,
  unknown;

  factory QueueStatus.fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return QueueStatus.active;
      case 'paused':
        return QueueStatus.paused;
      case 'closed':
        return QueueStatus.closed;
      case 'completed':
        return QueueStatus.completed;
      default:
        return QueueStatus.unknown;
    }
  }

  String get value {
    switch (this) {
      case QueueStatus.active:
        return 'active';
      case QueueStatus.paused:
        return 'paused';
      case QueueStatus.closed:
        return 'closed';
      case QueueStatus.completed:
        return 'completed';
      case QueueStatus.unknown:
        return 'unknown';
    }
  }
}

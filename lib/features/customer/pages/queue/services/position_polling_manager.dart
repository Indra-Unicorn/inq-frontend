import 'dart:async';
import '../../../models/customer_queue_summary.dart';
import 'queue_status_service.dart';
import 'polling_config.dart';

class PositionPollingManager {
  final Map<String, StreamSubscription<CustomerQueue>> _subscriptions = {};
  final Map<String, DateTime> _lastUpdateTimes = {};
  final Function(CustomerQueue) _onPositionUpdate;
  final Function(String, String) _onError;

  PositionPollingManager({
    required Function(CustomerQueue) onPositionUpdate,
    required Function(String, String) onError,
  })  : _onPositionUpdate = onPositionUpdate,
        _onError = onError;

  void startPolling(List<CustomerQueue> currentQueues) {
    // Stop existing polling
    stopAllPolling();

    if (PollingConfig.enableLogging) {
      print(
          'Starting ${PollingConfig.getStrategyDescription()} for ${currentQueues.length} queues');
    }

    // Start polling for each current queue
    for (final queue in currentQueues) {
      _startPollingForQueue(queue.qid);
    }
  }

  void _startPollingForQueue(String queueId) {
    if (_subscriptions.containsKey(queueId)) {
      if (PollingConfig.enableLogging) {
        print('Already polling queue: $queueId');
      }
      return; // Already polling this queue
    }

    try {
      if (PollingConfig.enableLogging) {
        print(
            'Starting polling for queue: $queueId using ${PollingConfig.getStrategyDescription()}');
      }

      // Use unified polling method that automatically selects the configured strategy
      final subscription = QueueStatusService.pollQueuePosition(queueId).listen(
        (updatedQueue) {
          if (PollingConfig.enableLogging) {
            print(
                'Received update for queue: ${updatedQueue.qid}, position: ${updatedQueue.currentRank}');
          }
          // Update the last update time for this queue
          _lastUpdateTimes[queueId] = DateTime.now();
          _onPositionUpdate(updatedQueue);
        },
        onError: (error) {
          if (PollingConfig.enableLogging) {
            print('Polling error for queue $queueId: $error');
          }
          _onError(queueId, error.toString());
        },
      );

      _subscriptions[queueId] = subscription;
    } catch (e) {
      if (PollingConfig.enableLogging) {
        print('Failed to start polling for queue $queueId: $e');
      }
      _onError(queueId, e.toString());
    }
  }

  void stopPollingForQueue(String queueId) {
    final subscription = _subscriptions[queueId];
    if (subscription != null) {
      if (PollingConfig.enableLogging) {
        print('Stopping polling for queue: $queueId');
      }
      subscription.cancel();
      _subscriptions.remove(queueId);
      _lastUpdateTimes.remove(queueId);
    }
  }

  void stopAllPolling() {
    if (PollingConfig.enableLogging) {
      print('Stopping all polling for ${_subscriptions.length} queues');
    }
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _lastUpdateTimes.clear();
  }

  bool isPolling(String queueId) {
    return _subscriptions.containsKey(queueId);
  }

  List<String> getPollingQueueIds() {
    return _subscriptions.keys.toList();
  }

  int getActivePollingCount() {
    return _subscriptions.length;
  }

  DateTime? getLastUpdateTime(String queueId) {
    return _lastUpdateTimes[queueId];
  }

  Map<String, DateTime> getAllLastUpdateTimes() {
    return Map.from(_lastUpdateTimes);
  }

  void dispose() {
    stopAllPolling();
  }
}

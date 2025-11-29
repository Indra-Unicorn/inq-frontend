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
      // Starting polling for queues
    }

    // Start polling for each current queue
    for (final queue in currentQueues) {
      _startPollingForQueue(queue.qid);
    }
  }

  void _startPollingForQueue(String queueId) {
    if (_subscriptions.containsKey(queueId)) {
      if (PollingConfig.enableLogging) {
        // Already polling this queue
      }
      return; // Already polling this queue
    }

    try {
      if (PollingConfig.enableLogging) {
        // Starting polling for queue
      }

      // Use unified polling method that automatically selects the configured strategy
      final subscription = QueueStatusService.pollQueuePosition(queueId).listen(
        (updatedQueue) {
          if (PollingConfig.enableLogging) {
            // Received update for queue
          }
          // Update the last update time for this queue
          _lastUpdateTimes[queueId] = DateTime.now();
          _onPositionUpdate(updatedQueue);
        },
        onError: (error) {
          if (PollingConfig.enableLogging) {
            // Error in polling
          }
          _onError(queueId, error.toString());
        },
      );

      _subscriptions[queueId] = subscription;
    } catch (e) {
      if (PollingConfig.enableLogging) {
        // Error starting polling
      }
      _onError(queueId, e.toString());
    }
  }

  void stopPollingForQueue(String queueId) {
    final subscription = _subscriptions[queueId];
    if (subscription != null) {
      if (PollingConfig.enableLogging) {
        // Stopping polling for queue
      }
      subscription.cancel();
      _subscriptions.remove(queueId);
      _lastUpdateTimes.remove(queueId);
    }
  }

  void stopAllPolling() {
    if (PollingConfig.enableLogging) {
      // Stopping all polling
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

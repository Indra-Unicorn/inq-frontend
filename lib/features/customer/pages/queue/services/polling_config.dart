enum PollingStrategy {
  shortPolling,
  longPolling,
  hybridPolling,
  adaptivePolling,
}

class PollingConfig {
  // Polling strategy to use
  static const PollingStrategy strategy = PollingStrategy.adaptivePolling;

  // Short polling configuration
  static const int shortPollInterval = 5; // seconds
  static const int shortPollErrorRetry = 10; // seconds

  // Long polling configuration
  static const int longPollTimeout = 30; // seconds
  static const int longPollErrorRetry = 10; // seconds

  // Hybrid polling configuration
  static const int hybridLongPollTimeout = 30; // seconds
  static const int hybridMinDelayBetweenRequests = 2; // seconds
  static const int hybridErrorRetryDelay = 10; // seconds

  // Adaptive polling configuration
  static const int adaptiveLongPollTimeout = 30; // seconds
  static const int adaptiveErrorRetryDelay = 10; // seconds
  static const int adaptiveMaxDelay = 30; // seconds
  static const int adaptiveCriticalPosition =
      3; // positions <= this get no delay

  // General configuration
  static const int maxRetries = 3;
  static const bool enableLogging = true;

  // Get the appropriate timeout based on strategy
  static int getTimeout() {
    switch (strategy) {
      case PollingStrategy.shortPolling:
        return 10; // Short timeout for short polling
      case PollingStrategy.longPolling:
        return longPollTimeout;
      case PollingStrategy.hybridPolling:
        return hybridLongPollTimeout;
      case PollingStrategy.adaptivePolling:
        return adaptiveLongPollTimeout;
    }
  }

  // Get the appropriate retry delay based on strategy
  static int getErrorRetryDelay() {
    switch (strategy) {
      case PollingStrategy.shortPolling:
        return shortPollErrorRetry;
      case PollingStrategy.longPolling:
        return longPollErrorRetry;
      case PollingStrategy.hybridPolling:
        return hybridErrorRetryDelay;
      case PollingStrategy.adaptivePolling:
        return adaptiveErrorRetryDelay;
    }
  }

  // Get the minimum delay between requests
  static int getMinDelayBetweenRequests() {
    switch (strategy) {
      case PollingStrategy.shortPolling:
        return shortPollInterval;
      case PollingStrategy.longPolling:
        return 0; // No delay for pure long polling
      case PollingStrategy.hybridPolling:
        return hybridMinDelayBetweenRequests;
      case PollingStrategy.adaptivePolling:
        return 0; // Will be calculated dynamically
    }
  }

  // Calculate adaptive delay based on queue position
  static int getAdaptiveDelay(int currentPosition) {
    if (currentPosition <= adaptiveCriticalPosition) {
      return 3; // No delay for critical positions (≤3)
    }

    // Linear increase from 0 to adaptiveMaxDelay
    // Formula: delay = (position - critical) * (maxDelay / (30 - critical))
    final delay = (currentPosition - adaptiveCriticalPosition) *
        (adaptiveMaxDelay / (30 - adaptiveCriticalPosition));

    // Ensure delay doesn't exceed max
    return delay.round().clamp(0, adaptiveMaxDelay);
  }

  // Get strategy description for UI
  static String getStrategyDescription() {
    switch (strategy) {
      case PollingStrategy.shortPolling:
        return 'Short Polling (5s)';
      case PollingStrategy.longPolling:
        return 'Long Polling (Real-time)';
      case PollingStrategy.hybridPolling:
        return 'Hybrid Polling (2s delay)';
      case PollingStrategy.adaptivePolling:
        return 'Adaptive Polling (0-30s)';
    }
  }
}

# Queue Position Polling System

This directory contains the implementation of a flexible queue position polling system with support for multiple polling strategies.

## Overview

The system provides real-time queue position updates using configurable polling strategies that balance responsiveness, server load, and battery efficiency.

## Polling Strategies

### 1. Short Polling
- **How it works**: Makes requests at fixed intervals (5 seconds)
- **Pros**: Simple, reliable, works with any HTTP server
- **Cons**: Higher server load, less real-time
- **Best for**: Development, testing, simple implementations

### 2. Long Polling
- **How it works**: Server holds connection until data changes, then responds immediately
- **Pros**: Most real-time, lower server load
- **Cons**: More complex, requires server support
- **Best for**: Production with proper server implementation

### 3. Hybrid Polling (Default)
- **How it works**: Long polling with minimum delay between requests (2 seconds)
- **Pros**: Good balance of real-time updates and resource efficiency
- **Cons**: Slightly higher latency than pure long polling
- **Best for**: Mobile applications, production use

## Configuration

Edit `polling_config.dart` to change the polling strategy:

```dart
class PollingConfig {
  // Change this to switch strategies
  static const PollingStrategy strategy = PollingStrategy.hybridPolling;
  
  // Adjust timing parameters
  static const int hybridLongPollTimeout = 30; // seconds
  static const int hybridMinDelayBetweenRequests = 2; // seconds
  static const int hybridErrorRetryDelay = 10; // seconds
}
```

## Architecture

### Core Components

1. **PollingConfig** (`polling_config.dart`)
   - Centralized configuration for all polling strategies
   - Easy switching between strategies
   - Configurable timeouts and delays

2. **QueueStatusService** (`queue_status_service.dart`)
   - Unified polling method that routes to appropriate strategy
   - Handles authentication and error management
   - Provides fallback mechanisms

3. **PositionPollingManager** (`position_polling_manager.dart`)
   - Manages multiple queue polling streams
   - Handles lifecycle (start/stop) for app state changes
   - Provides callbacks for updates and errors

### Usage Example

```dart
// Initialize polling manager
final pollingManager = PositionPollingManager(
  onPositionUpdate: (queue) => handlePositionUpdate(queue),
  onError: (queueId, error) => handleError(queueId, error),
);

// Start polling for current queues
pollingManager.startPolling(currentQueues);

// Stop polling when leaving page
pollingManager.stopAllPolling();
```

## API Endpoints

- **Queue Summary**: `GET /api/queue-manager/customer/summary`
- **Position Updates**: `GET /api/queue-manager/{queueId}/position`
- **Leave Queue**: `POST /api/queue-manager/{queueId}/leave`

## Error Handling

The system includes robust error handling:
- **Network errors**: Automatic retry with exponential backoff
- **Authentication errors**: Clear error messages
- **Server errors**: Graceful degradation
- **Timeouts**: Expected for long polling, handled gracefully

## Performance Considerations

### Mobile Optimization
- **Battery efficient**: Pauses polling when app is backgrounded
- **Network friendly**: Reduces unnecessary requests
- **Memory efficient**: Proper cleanup of streams and subscriptions

### Server Load
- **Hybrid polling**: Reduces server load compared to short polling
- **Configurable delays**: Prevents overwhelming the server
- **Connection pooling**: Efficient use of HTTP connections

## Monitoring and Debugging

Enable logging by setting `PollingConfig.enableLogging = true`:

```dart
// Logs will show:
// - Polling start/stop events
// - Position updates received
// - Error conditions
// - Strategy being used
```

## Migration Guide

### From Short Polling to Hybrid
1. Change `PollingConfig.strategy` to `PollingStrategy.hybridPolling`
2. No other code changes needed
3. Test with your backend to ensure long polling support

### From Hybrid to Long Polling
1. Change `PollingConfig.strategy` to `PollingStrategy.longPolling`
2. Ensure your backend supports holding connections
3. Monitor for timeout issues

## Best Practices

1. **Use Hybrid Polling** for most production scenarios
2. **Test with your backend** to ensure compatibility
3. **Monitor server load** and adjust delays as needed
4. **Handle app lifecycle** properly (background/foreground)
5. **Provide user feedback** for polling status 
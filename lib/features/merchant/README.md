# Merchant Dashboard - Modular Architecture

This directory contains the merchant dashboard feature, which has been refactored following design principles to improve maintainability, testability, and code organization.

## Architecture Overview

The merchant dashboard follows a **Component-Based Architecture** with **Separation of Concerns** and **Single Responsibility Principle**.

### Design Principles Applied

1. **Single Responsibility Principle (SRP)**: Each class has one reason to change
2. **Open/Closed Principle (OCP)**: Open for extension, closed for modification
3. **Dependency Inversion Principle (DIP)**: High-level modules don't depend on low-level modules
4. **Component-Based Architecture**: Reusable, self-contained components
5. **State Management**: Centralized state management using Provider pattern

## File Structure

```
lib/features/merchant/
├── controllers/
│   └── merchant_dashboard_controller.dart    # Business logic & state management
├── components/
│   ├── dashboard_header.dart                 # Reusable header component
│   ├── stats_summary_card.dart               # Statistics display component
│   ├── queue_list_header.dart                # Queue list header component
│   ├── queue_list.dart                       # Queue list with state handling
│   ├── loading_error_states.dart             # Loading, error, empty states
│   ├── merchant_bottom_navigation.dart       # Bottom navigation component
│   ├── queue_card.dart                       # Individual queue card
│   └── create_queue_dialog.dart              # Queue creation dialog
├── models/
│   └── merchant_queue.dart                   # Data models
├── services/
│   └── merchant_queue_service.dart           # API services
└── merchant_dashboard.dart                   # Main dashboard page
```

## Components Breakdown

### 1. Controller (`merchant_dashboard_controller.dart`)
- **Responsibility**: Business logic and state management
- **Features**:
  - Queue data management
  - API calls coordination
  - Loading and error state handling
  - Computed properties (total queues, active queues, etc.)

### 2. UI Components

#### `dashboard_header.dart`
- **Responsibility**: Page header with title and action button
- **Reusability**: Can be used across different merchant pages
- **Features**: Configurable title, add button, and tooltips

#### `stats_summary_card.dart`
- **Responsibility**: Display dashboard statistics
- **Features**: 
  - Total queues count
  - Active queues count
  - Total customers count
  - Gradient background with icons

#### `queue_list_header.dart`
- **Responsibility**: Queue list section header
- **Features**: Title and refresh button

#### `queue_list.dart`
- **Responsibility**: Queue list with state handling
- **Features**:
  - Loading state
  - Error state with retry
  - Empty state with call-to-action
  - Pull-to-refresh functionality
  - Queue card rendering

#### `loading_error_states.dart`
- **Responsibility**: Reusable state components
- **Components**:
  - `LoadingState`: Loading spinner with message
  - `ErrorState`: Error display with retry button
  - `EmptyState`: Empty state with action button

#### `merchant_bottom_navigation.dart`
- **Responsibility**: Bottom navigation bar
- **Features**: Navigation between queues and profile

## Benefits of This Architecture

### 1. **Maintainability**
- Each component has a single responsibility
- Easy to locate and modify specific functionality
- Clear separation between UI and business logic

### 2. **Testability**
- Controller can be tested independently
- UI components can be unit tested
- Mock dependencies easily

### 3. **Reusability**
- Components can be reused across different pages
- Consistent UI patterns throughout the app
- Easy to create variations of components

### 4. **Scalability**
- Easy to add new features
- Components can be extended without modifying existing code
- Clear structure for new developers

### 5. **Performance**
- Efficient state management with Provider
- Minimal rebuilds due to granular components
- Lazy loading capabilities

## State Management

The dashboard uses the **Provider pattern** for state management:

- **Controller**: Extends `ChangeNotifier` for reactive state updates
- **Consumer**: Widgets listen to state changes automatically
- **Separation**: UI components are stateless, controller handles all state

## Future Enhancements

1. **Add more reusable components** for common UI patterns
2. **Implement caching** for better performance
3. **Add unit tests** for controller and components
4. **Create widget tests** for UI components
5. **Add animations** for better user experience

## Best Practices

1. **Keep components small and focused**
2. **Use meaningful component names**
3. **Document complex business logic**
4. **Follow consistent naming conventions**
5. **Test components in isolation**
6. **Use proper error handling**
7. **Implement loading states for better UX** 
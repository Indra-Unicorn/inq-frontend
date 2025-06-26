# Authentication Flow & Token Storage

## Overview

This implementation provides persistent authentication for both web and mobile platforms using local storage/cache. Users will remain logged in until they explicitly logout or their token expires.

## Key Components

### 1. AuthService (`lib/services/auth_service.dart`)

Central service for managing authentication data:

- **Token Storage**: Securely stores JWT tokens in SharedPreferences
- **Token Validation**: Checks token expiration and validates with server
- **Token Refresh**: Automatically refreshes expired tokens
- **User Data Management**: Stores and retrieves user information
- **Logout**: Clears all authentication data

### 2. SplashScreen (`lib/features/auth/splash_screen.dart`)

Initial screen that:
- Shows app branding
- Checks for existing authentication
- Validates stored tokens
- Routes users to appropriate screens

### 3. Updated Services

All services now use `AuthService.getToken()` instead of directly accessing SharedPreferences:
- ProfileService
- QueueService
- ShopService
- QueueStatusService
- MerchantProfileService
- MerchantQueueService

## Authentication Flow

### 1. App Startup
```
SplashScreen → Check AuthService.isLoggedIn() → Route to appropriate screen
```

### 2. Login Process
```
Login Page → OTP Verification → AuthService.storeAuthData() → Dashboard
```

### 3. Token Management
```
API Request → AuthService.getToken() → Check expiration → Refresh if needed → Use token
```

### 4. Logout Process
```
Logout → AuthService.clearAuthData() → Navigate to Login
```

## Token Storage Details

### Stored Data
- **auth_token**: JWT token for API authentication
- **user_data**: User information (name, type, ID, etc.)
- **refresh_token**: Token for refreshing expired JWT
- **login_time**: Timestamp of login for analytics

### Token Expiration Handling
- Tokens are considered expired 5 minutes before actual expiration
- Automatic refresh attempts when token is near expiration
- Fallback to login if refresh fails

### Platform Support
- **Mobile**: Uses SharedPreferences (iOS/Android)
- **Web**: Uses localStorage (Chrome/Firefox/Safari)
- **Desktop**: Uses SharedPreferences (macOS/Windows/Linux)

## Security Features

1. **Token Validation**: Server-side validation on each request
2. **Automatic Refresh**: Seamless token renewal
3. **Secure Storage**: Uses platform-specific secure storage
4. **Expiration Handling**: Proactive token management
5. **Clean Logout**: Complete data removal on logout

## Usage Examples

### Check if user is logged in
```dart
bool isLoggedIn = await AuthService.isLoggedIn();
```

### Get authentication token
```dart
String? token = await AuthService.getToken();
```

### Get user data
```dart
Map<String, dynamic>? userData = await AuthService.getUserData();
```

### Logout user
```dart
await AuthService.clearAuthData();
```

### Store new authentication
```dart
await AuthService.storeAuthData(
  token: 'jwt_token',
  userData: {'name': 'John', 'userType': 'CUSTOMER'},
  refreshToken: 'refresh_token',
);
```

## Benefits

1. **Persistent Sessions**: Users stay logged in across app restarts
2. **Seamless Experience**: No repeated login requirements
3. **Cross-Platform**: Works on all supported platforms
4. **Automatic Management**: Handles token expiration transparently
5. **Secure**: Uses platform-specific secure storage
6. **Maintainable**: Centralized authentication logic

## Error Handling

- Network errors during token refresh
- Invalid or expired tokens
- Missing authentication data
- Server validation failures

All errors are handled gracefully with fallback to login screen when necessary. 
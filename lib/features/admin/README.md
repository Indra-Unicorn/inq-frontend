# Admin Module - Architecture Documentation

This directory contains the admin module, following the same modular architecture pattern as the customer and merchant modules for better code separation and maintainability.

## Architecture Overview

The admin module follows a **Modular Architecture** with **Separation of Concerns** and **Single Responsibility Principle**, consistent with the rest of the application.

### Design Principles Applied

1. **Single Responsibility Principle (SRP)**: Each class has one reason to change
2. **Modular Architecture**: Separate module for admin functionality
3. **Separation of Concerns**: Clear separation between UI, services, and models
4. **Consistent Patterns**: Follows the same patterns as customer and merchant modules

## File Structure

```
lib/features/admin/
├── pages/
│   ├── admin_login_page.dart      # Admin login page
│   └── admin_dashboard.dart        # Admin dashboard (placeholder)
└── README.md                       # This file
```

## Components Breakdown

### 1. Admin Login Page (`admin_login_page.dart`)
- **Responsibility**: Admin authentication interface
- **Features**:
  - Admin login form with identifier and password fields
  - API integration with `/api/auth/login/admin` endpoint
  - Token storage using AuthService
  - FCM token registration for notifications
  - Navigation to admin dashboard on successful login
  - Error handling and loading states

**API Details**:
- **Endpoint**: `POST /api/auth/login/admin`
- **Request Body**:
  ```json
  {
    "identifier": "admin",
    "password": "admin"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "Admin login successful",
    "data": {
      "userType": "ADMIN",
      "token": "...",
      "email": "admin",
      "name": "aman",
      "id": "...",
      "phoneNumber": null,
      "status": null
    }
  }
  ```

### 2. Admin Dashboard (`admin_dashboard.dart`)
- **Responsibility**: Main admin interface (placeholder)
- **Features**:
  - Welcome section with user information
  - Logout functionality
  - Placeholder for future admin features

## Hidden Access Mechanism

The admin login page is accessible through a hidden mechanism on the merchant login page:

- **Trigger**: Click the merchant login button 5 times within 5 seconds
- **Location**: Merchant login page (`lib/features/auth/merchant_login.dart`)
- **Behavior**: 
  - Tracks button clicks within a 5-second window
  - Automatically resets if 5 seconds pass without reaching 5 clicks
  - Navigates to admin login page when triggered
  - Normal login functionality continues if admin access is not triggered

## Authentication Flow

1. User triggers hidden admin access (5 clicks in 5 seconds on merchant login)
2. Admin login page is displayed
3. User enters identifier and password
4. API call to `/api/auth/login/admin`
5. On success:
   - Token and user data stored via AuthService
   - FCM token registered (mobile platforms only)
   - Navigation to admin dashboard
6. On failure:
   - Error message displayed
   - User remains on login page

## State Management

- Uses Flutter's built-in `StatefulWidget` for local state
- AuthService for global authentication state
- SharedPreferences for persistent storage

## Future Enhancements

The admin module is currently a placeholder. Future features may include:

1. **User Management**
   - View all users (customers, merchants)
   - Manage user status
   - View user details

2. **Queue Management**
   - View all queues across the platform
   - Monitor queue activity
   - Manage queue status

3. **Analytics Dashboard**
   - Platform statistics
   - User activity metrics
   - Queue performance metrics

4. **System Settings**
   - Platform configuration
   - Feature flags
   - System maintenance

5. **Reports**
   - Generate reports
   - Export data
   - View logs

## Best Practices

1. **Keep components modular and reusable**
2. **Follow consistent naming conventions**
3. **Use proper error handling**
4. **Implement loading states for better UX**
5. **Document API endpoints and data structures**
6. **Maintain separation of concerns**

## Security Considerations

- Admin access is hidden but not encrypted - consider additional security measures for production
- Admin credentials should be stored securely
- Consider implementing role-based access control (RBAC)
- Add rate limiting for login attempts
- Implement session management

## Dependencies

- `http`: For API calls
- `shared_preferences`: For local storage
- `jwt_decoder`: For token decoding
- `firebase_messaging`: For push notifications
- `flutter/foundation`: For platform detection

## Related Files

- `lib/services/auth_service.dart`: Authentication service
- `lib/shared/constants/api_endpoints.dart`: API endpoint definitions
- `lib/features/auth/merchant_login.dart`: Hidden access trigger location


# Sharable Store Links

This document explains how the sharable store links feature works in the InQ app.

## Overview

Store details pages now use URL-based navigation with shop IDs. This ensures consistent URLs across the app and makes sharing more reliable. All store navigation now uses the format `/store/{shopId}`.

## URL Format

### App Navigation
```
/store/{shopId}
```

### Web URLs (for sharing)
```
{domain}/store/{shopId}
```

### Deep Links
```
inq://store/{shopId}
```

Where `{shopId}` is the unique identifier for the store and `{domain}` is automatically extracted from the API base URL.

## Implementation Details

### 1. Dynamic Domain Extraction

The app automatically extracts the domain from the API base URL using the `AppConstants.getShareableDomain()` method:

```dart
static String getShareableDomain() {
  try {
    final uri = Uri.parse(ApiEndpoints.baseUrl);
    return '${uri.scheme}://${uri.host}';
  } catch (e) {
    // Fallback to a default domain if parsing fails
    return 'https://inqueue.in';
  }
}
```

This ensures that:
- Development environments use the correct domain
- Production environments use the production domain
- Fallback to a default domain if parsing fails

### 2. URL-Based Navigation

All store navigation now uses the shop ID in the URL:

```dart
// From customer dashboard
void _onStoreTap(Shop store) {
  Navigator.pushNamed(
    context,
    '/store/${store.shopId}',
  );
}
```

### 3. Routing Configuration

The app's routing in `main.dart` handles store navigation through `onGenerateRoute`:

```dart
onGenerateRoute: (settings) {
  // Handle store details with shop ID in URL
  if (settings.name?.startsWith('/store/') == true) {
    final shopId = settings.name!.substring('/store/'.length);
    return MaterialPageRoute(
      builder: (context) => StoreDetailsPage(shopId: shopId),
      settings: settings,
    );
  }
  return null;
},
```

### 4. Store Details Page

The `StoreDetailsPage` now always fetches store data using the shop ID:

```dart
class StoreDetailsPage extends StatefulWidget {
  final String shopId;

  const StoreDetailsPage({
    super.key,
    required this.shopId,
  });
}
```

### 5. Share Functionality

The share button creates shareable links with:
- Store name and address
- Store categories (if available)
- Dynamic web URL based on API domain
- Deep link URL for app navigation
- Custom message

### 6. API Integration

The `ShopService.getShopById()` method fetches store details:

```dart
Future<Shop> getShopById(String shopId) async {
  // API call to fetch shop details by ID
}
```

## Usage Examples

### Navigating to a Store
1. From the customer dashboard, tap any store
2. The app navigates to `/store/{shopId}`
3. Store details are fetched using the shop ID
4. URL in the browser/app shows the shop ID

### Sharing a Store
1. Navigate to any store details page
2. Tap the share button (📤) in the header
3. Choose your preferred sharing method
4. The recipient receives both a web link and deep link:
   - Web: `https://lnq-production.up.railway.app/store/abc123`
   - App: `inq://store/abc123`

### Opening a Shared Link
1. Receive a shared store link
2. Tap the link (if supported by the device)
3. The app opens directly to the store details page
4. If the app isn't installed, it can redirect to the app store

## Benefits

### 1. Consistent URLs
- All store pages have URLs with shop IDs
- URLs are shareable and bookmarkable
- SEO-friendly URLs for web versions

### 2. Reliable Navigation
- No dependency on passing Shop objects
- Always fetches fresh data from the API
- Handles edge cases better

### 3. Better Sharing
- URLs are consistent across all platforms
- Deep links work reliably
- Web fallbacks are available

## Environment Support

The dynamic domain extraction supports different environments:

- **Development**: Uses the development API domain
- **Staging**: Uses the staging API domain  
- **Production**: Uses the production API domain
- **Fallback**: Uses `https://inqueue.in` if parsing fails

## Error Handling

The implementation includes proper error handling:
- Loading states while fetching store data
- Error messages if the store is not found
- Fallback to clipboard if sharing fails
- Graceful handling of invalid shop IDs
- Domain extraction fallback if API URL parsing fails

## Future Enhancements

Potential improvements for the future:
1. Add web fallback URLs for non-app users
2. Implement analytics for shared link usage
3. Add QR code generation for store links
4. Support for sharing specific queues within stores
5. Add social media preview metadata for web links
6. Support for custom domain configuration
7. Add URL shortening for very long shop IDs 
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app `inq` — a queue-management product with three user roles (CUSTOMER, MERCHANT, ADMIN) targeting iOS, Android, and web (Firebase Hosting). Backend is a separate REST service at `https://lnq-production.up.railway.app/api` (configured in `lib/shared/constants/api_endpoints.dart`; flip the commented line to point at `localhost:8080` for local backend work).

Dart SDK `>=3.2.3 <4.0.0`; CI uses Flutter `3.24.0` stable.

## Common commands

```bash
flutter pub get                         # install deps
flutter run                             # run on connected device/emulator
flutter run -d chrome                   # run web build
flutter build web --release             # production web build (Firebase Hosting reads build/web)
flutter analyze                         # static analysis (uses analysis_options.yaml -> flutter_lints)
flutter test                            # run all tests (only test/widget_test.dart exists)
flutter test test/widget_test.dart      # run a single test file
firebase deploy --only hosting          # manual web deploy (CI handles main automatically)
```

There is no separate lint command — `flutter analyze` is the lint gate.

## Architecture

### Navigation & app entry
`lib/main.dart` is the single source of truth for routing. All static routes are registered in `MaterialApp.routes`; the dynamic `/store/{shopId}` deep link is parsed in `onGenerateRoute`. Adding a screen means adding a route here — the splash screen's `_isValidRoute` / `_protectedRoutes` sets in `lib/features/auth/splash_screen.dart` must be updated in lockstep, otherwise web-URL deep links won't survive auth checks.

`SplashScreen` is the home widget and performs role-based routing on every cold start:
- On web, if the current URL is a known route, it honors that path (sending unauthenticated users to `/login` or `/admin-dashboard` → `/admin-login`).
- Otherwise it reads `AuthService.getUserType()` and routes CUSTOMER → `/customer-dashboard`, MERCHANT → `/merchant-dashboard`, ADMIN → `/admin-dashboard`.
- Logged-out users land on `/customer-dashboard` (the dashboard itself gates protected actions). `/login` is the customer/merchant chooser entry point.

After OTP login, customer flow falls back to `/customer-dashboard` unless `OtpVerificationPage.returnTo` was passed (used when a protected page bounced the user to login). Merchant login pushes `/merchant-dashboard`; admin login pushes `/admin-dashboard`.

### Hidden admin access
Admin login is reachable only by tapping the merchant-login submit button 5 times within 5 seconds (logic in `lib/features/auth/merchant_login.dart`). Do not surface admin entry points elsewhere.

### Auth & token lifecycle
`lib/services/auth_service.dart` is the only correct way to read/write auth state. It stores `auth_token`, `user_data`, `refresh_token`, `login_time` in `SharedPreferences` (which on web maps to `localStorage`). `getToken()` proactively refreshes 5 minutes before JWT expiry and clears storage on refresh failure. **All service-layer HTTP calls must go through `AuthService.getToken()`** — never read `SharedPreferences` directly for the token (the `SSEService` is the one legacy exception, see `lib/services/sse_service.dart`).

See `AUTHENTICATION_FLOW.md` for the full token lifecycle.

### Feature layout
`lib/features/{auth,customer,merchant,admin}/` each contain `pages/`, `services/`, and (where applicable) `models/`, `controllers/`, `components/`. Shared cross-feature code lives in:
- `lib/services/` — app-wide services (`auth_service.dart`, `notification_service.dart`, `sse_service.dart`)
- `lib/shared/constants/` — `api_endpoints.dart`, `app_constants.dart` (user/queue/merchant status string enums, storage keys), `app_colors.dart`
- `lib/shared/widgets/`, `lib/shared/utils/`, `lib/shared/common_style.dart`

The merchant dashboard is the only feature using Provider — `MerchantDashboardController extends ChangeNotifier` is wired up in the route definition in `main.dart`. The rest of the app uses plain `StatefulWidget` + service-class calls. Don't introduce Provider elsewhere without aligning with the existing pattern (see `lib/features/merchant/README.md`).

### Real-time queue updates
`SSEService` (singleton) attempts an SSE connection to `/queue-manager/.../stream` and falls back to 60-second polling if SSE fails. It manages its own reconnect/heartbeat timers. When touching live-queue UI, prefer subscribing to `SSEService().eventStream` rather than ad-hoc polling.

### Sharable links
Store pages use the URL form `/store/{shopId}` everywhere — in-app navigation, web URLs, and `inq://store/{shopId}` deep links. `StoreDetailsPage` always re-fetches by `shopId` rather than accepting a pre-loaded `Shop` object. See `SHARABLE_LINKS.md`.

### Firebase
`firebase_options.dart` is generated; web hosting config is in `firebase.json` (rewrites all paths to `/index.html` for SPA routing). Firebase init in `main.dart` swallows `duplicate-app` errors from hot reload. Push notifications are initialized post-`runApp` so they never block UI startup; on web this avoids the browser permission prompt at launch.

### CI
`.github/workflows/firebase-hosting-merge.yml` builds `flutter build web --release` and deploys to Firebase Hosting on every push to `main`. `firebase-hosting-pull-request.yml` builds preview channels for PRs. Breaking the web build breaks deploys — verify `flutter build web --release` locally before merging Flutter-version-sensitive changes.

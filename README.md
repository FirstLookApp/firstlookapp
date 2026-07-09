# FirstLook Mobile App

Flutter mobile client for FirstLook. The app lets users discover mobile products, join tests, like and comment on apps, submit their own applications, track notifications, and manage their profile.

The UI follows the Figma file as the source of truth. API integrations target the staging backend by default.

## Current Status

The app is buildable and wired to real staging endpoints for the implemented flows.

Implemented areas:

- Splash and auth gate
- Login
- Register
- OTP verification
- Forgot/reset password
- Discover
- Drop / Test tabs
- Application detail
- Like / unlike
- Store click tracking
- Comments
- Liked items
- Profile
- Submit application with multipart screenshot upload
- Beta access request
- Notifications
- Logout with access/refresh token cache clearing

## Tech Stack

- Flutter
- Dart
- Riverpod
- Dio
- GoRouter
- Flutter Secure Storage
- Hive
- Flutter localization
- `file_picker`
- `url_launcher`
- Environment-based configuration with `flutter_dotenv`

## Requirements

- Flutter SDK
- Dart SDK
- Android SDK
- Java 17

Android Studio is not required for this repository workflow.

Known working local setup:

- Flutter: 3.41.7
- Dart: 3.11.5
- Android SDK: `C:\Users\husey\AppData\Local\Android\Sdk`
- Java: `C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot`

## Environment

Environment files are included in the project root:

- `.env.dev`
- `.env.staging`
- `.env.production`

Staging configuration:

```env
APP_ENV=staging
API_BASE_URL=https://staging-api.firstlookapps.com
CONNECT_TIMEOUT_MS=30000
RECEIVE_TIMEOUT_MS=30000
SEND_TIMEOUT_MS=30000
```

Do not hardcode API URLs in widgets or feature files. Use the environment configuration and `ApiPaths`.

## API

Swagger:

```text
https://staging-api.firstlookapps.com/swagger
```

Base URL:

```text
https://staging-api.firstlookapps.com
```

Connected endpoints:

- `POST /api/auth/register`
- `POST /api/auth/verify-email`
- `POST /api/auth/resend-otp`
- `GET /api/auth/username-availability`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `POST /api/auth/refresh-token`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`
- `GET /api/profile/me`
- `GET /api/profile/favorites`
- `GET /api/profile/notifications`
- `GET /api/profile/notifications/unread-count`
- `POST /api/profile/notifications/{notificationId}/read`
- `GET /api/discovery/{destination}`
- `GET /api/discovery/{destination}/list`
- `GET /api/discovery/{applicationId}/detail`
- `POST /api/interactions/{applicationId}/like`
- `GET /api/interactions/{applicationId}/comments`
- `POST /api/interactions/{applicationId}/comments`
- `POST /api/interactions/{applicationId}/store-click`
- `POST /api/interactions/{applicationId}/beta-request`
- `POST /api/applications`
- `GET /api/applications/mine`

Available but not fully wired in the mobile UI yet:

- `POST /api/profile/select-avatar`
- `PUT /api/applications/{applicationId}`
- `GET /api/applications/my-beta-requests`
- `POST /api/interactions/comments/{commentId}/report`

## Known Product / API Gaps

- Profile comments: the mobile UI has a clean placeholder because Swagger does not expose a dedicated "my comments" endpoint for the current user.
- Edit submitted application: the backend has `PUT /api/applications/{applicationId}`, but the edit flow is not part of the current Figma pass yet.
- My beta requests: the backend has `GET /api/applications/my-beta-requests`, but no matching mobile screen has been implemented yet.
- Avatar selection: the backend has `POST /api/profile/select-avatar`, but the current profile screen only displays the selected avatar/initial.

## Run

Install dependencies:

```bash
flutter pub get
```

Generate localization files:

```bash
flutter gen-l10n
```

Run on a connected emulator/device:

```bash
flutter run -d emulator-5554
```

Build Android debug APK:

```bash
flutter build apk --debug
```

## Quality Checks

Run before committing:

```bash
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

Last verified during emulator QA:

- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

## Architecture Notes

- Keep business logic out of widgets.
- Use Riverpod providers/controllers for feature state and API actions.
- Use Dio through the configured API client.
- Store tokens only through secure token storage.
- Keep user-facing strings in localization files.
- Keep API paths centralized in `lib/core/network/api_paths.dart`.
- Keep reusable visual pieces under `lib/widgets` or feature widgets.

## UI Rules

- Figma is the single source of truth.
- Do not redesign screens without a matching Figma update.
- Do not use mock data when a real endpoint exists.
- Do not hardcode URLs or strings.
- Keep the app buildable after every change.

## Repository

```text
https://github.com/FirstLookApp/firstlookapp
```

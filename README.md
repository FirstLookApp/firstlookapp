# FirstLook Mobile App

FirstLook mobile app is a Flutter application for discovering, testing, liking, commenting on and submitting mobile applications.

The app follows the existing clean architecture approach and uses real staging API endpoints whenever they are available.

## Current Status

The Flutter project foundation is ready and buildable.

Implemented app areas:

- Splash
- Login
- Register
- OTP verification
- Forgot password
- Discover
- Drop / Test tabs
- Application detail
- Like / unlike
- Store click tracking
- Comments
- Liked items
- Profile
- Submit application placeholder
- Beta access request
- Notifications

## Tech Stack

- Flutter
- Dart
- Riverpod
- Dio
- GoRouter
- Flutter Secure Storage
- Hive
- Flutter localization
- Environment-based configuration

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

Do not hardcode API URLs in widgets or feature files. Use the environment configuration.

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
- `POST /api/profile/select-avatar`
- `GET /api/discovery/{destination}`
- `GET /api/discovery/{destination}/list`
- `GET /api/discovery/{applicationId}/detail`
- `POST /api/interactions/{applicationId}/like`
- `GET /api/interactions/{applicationId}/comments`
- `POST /api/interactions/{applicationId}/comments`
- `POST /api/interactions/{applicationId}/store-click`
- `POST /api/interactions/{applicationId}/beta-request`
- `GET /api/profile/favorites`
- `GET /api/profile/notifications`
- `GET /api/applications/mine`
- `GET /api/applications/my-beta-requests`

Available but not fully wired yet:

- `POST /api/applications`
- `PUT /api/applications/{applicationId}`

## Missing API / TODO

These are intentionally left as clean TODOs because the matching endpoint or final wiring is not available yet.

- Submit application: multipart endpoint exists, but screenshot/file upload UI wiring still needs completion.

When new API endpoints arrive, update this section first and then wire the related feature.

## Run

Install dependencies:

```bash
flutter pub get
```

Generate localization files:

```bash
flutter gen-l10n
```

Run the app:

```bash
flutter run
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

Last verified checks:

- `dart format .`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

## Project Notes

- Figma is the single source of truth for UI.
- Do not redesign screens without a matching Figma update.
- Do not use mock data when a real endpoint exists.
- Do not put business logic inside widgets.
- Do not hardcode user-facing strings.
- Do not hardcode API URLs.
- Keep reusable widgets and feature logic deduplicated.
- Keep the app buildable after every change.

## Git Notes

The local implementation commit exists, but pushing to GitHub currently fails because the authenticated account does not have write access to the repository.

Observed push error:

```text
Write access to repository not granted.
HTTP 403
```

Repository:

```text
https://github.com/FirstLookApp/firstlookapp
```

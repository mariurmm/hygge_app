# Hygge App

A Flutter wellness & fitness scheduling app — book classes, track programs, manage your subscription, and stay notified.

![Flutter](https://img.shields.io/badge/Flutter-3.41.9-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.4-blue?logo=dart)
![License](https://img.shields.io/badge/license-private-lightgrey)

---

## Screenshots

<!-- Add screenshots here -->

---

## Features

- **Google Sign-In** — authentication via Firebase Auth + Google
- **Home feed** — personalized daily overview
- **Programs** — browse and view wellness/fitness programs with full detail pages
- **Schedule** — calendar-based class schedule with a date strip and booking flow
- **Booking** — class detail view and one-tap booking
- **Favourites** — save and revisit favourite programs
- **History** — session and booking history
- **Notifications** — push notifications via Firebase Messaging
- **Profile** — user profile with travel progress, recent sessions, monthly stats, and subscription status
- **Subscription** — view and manage account subscription
- **Settings** — app preferences (locale, theme, account)
- **Localisation** — multi-language support via ARB files

---

## Tech Stack

| Package | Purpose |
|---|---|
| `flutter_bloc` / `bloc` | State management (BLoC + Cubit) |
| `go_router` | Declarative navigation |
| `get_it` + `injectable` | Dependency injection |
| `freezed` + `json_serializable` | Immutable models & JSON serialisation |
| `firebase_auth` + `cloud_firestore` | Authentication & database |
| `firebase_messaging` | Push notifications |
| `firebase_storage` | Cloud file storage |
| `google_sign_in` | Google OAuth login |
| `hive_ce` | Local offline storage |
| `cloudinary` (via HTTP) | Avatar image uploads |
| `flutter_dotenv` | Environment variable loading |
| `shared_preferences` | Lightweight local key-value store |
| `connectivity_plus` | Network connectivity checks |
| `flutter_animate` | Widget animations |
| `very_good_analysis` | Strict lint ruleset |
| FVM | Flutter version management |

---

## Getting Started

### Prerequisites

- [FVM](https://fvm.app) — Flutter Version Management

```bash
dart pub global activate fvm
```

### Setup

```bash
# 1. Clone the repo
git clone <repo-url>
cd hygge_app

# 2. Install the pinned Flutter version
fvm install

# 3. Install dependencies
fvm flutter pub get

# 4. Set up environment variables
cp .env.example .env
# Open .env and fill in the required keys (see Environment Variables below)

# 5. Generate code (freezed, injectable, json_serializable)
fvm dart run build_runner build --delete-conflicting-outputs

# 6. Run the app
fvm flutter run
```

---

## Environment Variables

Copy `.env.example` to `.env` and populate:

| Key | Description |
|---|---|
| `SERVER_CLIENT_ID` | Google Sign-In OAuth server client ID |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary account/cloud name |
| `CLOUDINARY_UPLOAD_PRESET` | Cloudinary unsigned upload preset |
| `CLOUDINARY_AVATAR_FOLDER` | Cloudinary folder path for avatar images |

> `.env` is gitignored — never commit it.

---

## Project Structure

```
lib/
├── features/          # Feature modules — UI + BLoC/Cubit per feature
│   ├── app/           # Root app widget, AppBloc (auth), LocaleCubit
│   ├── app_shell/     # Bottom navigation shell
│   ├── home/          # Home tab
│   ├── programs/      # Programs tab (list + detail)
│   ├── programs_list/ # Program list sub-feature
│   ├── programs_detail/
│   ├── schedule/      # Schedule tab + calendar
│   ├── booking/       # Class detail + booking cubit
│   ├── favourites/    # Favourites BLoC
│   ├── history/       # Session history
│   ├── notifications/ # Push notification BLoC + UI
│   ├── profile/       # Profile tab + widgets
│   ├── subscription/  # Subscription screens + BLoC
│   ├── settings/      # Settings screen + BLoC
│   ├── login/         # Login screen
│   └── splash/        # Splash screen + BLoC
├── data/
│   ├── repositories/  # Data access layer
│   └── models/        # Freezed data models
├── core/
│   ├── router/        # GoRouter config + route name constants
│   ├── services/      # Firebase wrappers, Cloudinary service
│   ├── theme/         # App theme
│   └── utils/         # AppLogger, helpers
├── di/                # GetIt + Injectable setup
└── widgets/           # Shared reusable widgets
```

---

## Running Tests

```bash
# All tests
fvm flutter test

# Single test file
fvm flutter test test/features/settings/settings_bloc_test.dart
```

---

## Code Generation

Run after modifying any `freezed`, `injectable`, `json_serializable`, or Hive model:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

For continuous generation during development:

```bash
fvm dart run build_runner watch --delete-conflicting-outputs
```

> **Hive warning:** never change existing `@HiveType(typeId)` or `@HiveField` indices — this breaks stored data.

---

## Contributing

1. Format before committing: `fvm dart format lib test`
2. Lint must pass: `fvm flutter analyze`
3. Follow the `very_good_analysis` ruleset — no type annotations on closure parameters, trailing commas required, `prefer_const_constructors`.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## First-time setup

```bash
fvm install          # installs the pinned Flutter version from .fvmrc
fvm flutter pub get
cp .env.example .env # fill in required keys (see Environment section)
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter run
```

## Commands

```bash
# Run tests
fvm flutter test

# Run a single test file
fvm flutter test test/features/settings/settings_bloc_test.dart

# Lint
fvm flutter analyze

# Format
fvm dart format lib test

# Code generation (freezed, injectable, json_serializable, hive)
fvm dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
fvm dart run build_runner watch --delete-conflicting-outputs
```

Localization (`.arb` files in `l10n/`) is auto-generated on `flutter pub get` / `flutter run` — no separate command needed.

## Environment

Copy `.env.example` to `.env`. Required keys:

| Key | Description |
|-----|-------------|
| `SERVER_CLIENT_ID` | Google Sign-In server client ID |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary account name |
| `CLOUDINARY_UPLOAD_PRESET` | Cloudinary unsigned upload preset |
| `CLOUDINARY_AVATAR_FOLDER` | Cloudinary folder for avatar images |

`.env` is gitignored — never commit it.

## Architecture

### Layer Structure

```
lib/
├── features/      # Feature modules — each owns its UI and state
├── data/          # Repositories and models
│   ├── repositories/
│   └── models/
├── core/          # Shared infrastructure (router, theme, services, constants)
├── di/            # GetIt + Injectable dependency injection
└── widgets/       # Global reusable widgets
```

**No domain/use-case layer.** Business logic lives directly in BLoC/Cubit classes.

### Startup Sequence (`main.dart`)

1. Load `.env` via `flutter_dotenv`
2. `Firebase.initializeApp()`
3. `configureDependencies()` — registers all GetIt singletons
4. Wrap app in `MultiRepositoryProvider` (exposes all repositories via `context.read<Repo>()`)
5. `runApp(const App())`

### State Management

**BLoC pattern** throughout, using `bloc` / `flutter_bloc`:

- **BLoC** (event-driven) for complex flows: `AppBloc` (auth), `FavouritesBloc`, `NotificationsBloc`, `SettingsBloc`
- **Cubit** for simpler state: `HomeCubit`, `ScheduleCubit`, `BookingCubit`, `SubscriptionCubit`, `LocaleCubit`, `ProfileBloc`

**BLoC provision pattern:**
- **App-level** (`App` widget): `AppBloc`, `LocaleCubit`, `FavouritesBloc`
- **Shell-level** (`AppRouter` ShellRoute): `ScheduleCubit`, `BookingCubit`, `SubscriptionCubit`, `HomeCubit`, `NotificationsBloc`
- **Screen-level**: `ProfileBloc` (in `ProfileTab`), `SettingsBloc` (in `SettingsScreen`)

`AppBloc` holds the authenticated `UserModel` and drives auth-gated routing.
Read the user anywhere with `context.read<AppBloc>().state.user`.

### Navigation

GoRouter (`lib/core/router/app_router.dart`). Route constants in `lib/core/router/route_names.dart`.

Route structure:
- `/` → SplashScreen
- `/login` → LoginScreen
- `/home` → ShellRoute with `AppShell` (bottom nav)
  - `/home/main` → HomeTab
  - `/home/programs` → ProgramsTab
  - `/home/schedule` → ScheduleTab
  - `/home/profile` → ProfileTab
- `/home/settings`, `/home/notifications`, `/home/history`, `/home/subscription` — standalone screens

Navigate with `context.go(RouteNames.xxx)` or `context.push(RouteNames.xxx)`.
All transitions: 200ms `FadeTransition`.

### Dependency Injection

GetIt + Injectable. Registered at startup via `configureDependencies()` → `lib/di/injection.config.dart`.

Repositories are `@lazySingleton`. Access via:
- `getIt<SomeRepository>()` — in router/non-widget code
- `context.read<SomeRepository>()` — in widgets (tree wrapped in `MultiRepositoryProvider`)

After adding or changing an injectable class, re-run build_runner.

### Models

`freezed` for immutable data classes, `json_serializable` for Firestore serialization.

```dart
@freezed
abstract class SomeModel with _$SomeModel {
  const factory SomeModel({required String id, ...}) = _SomeModel;
  const SomeModel._(); // required for custom instance methods
  factory SomeModel.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
  static SomeModel get empty => const SomeModel(id: '', ...);
}
```

`NotificationItem` and `NotificationType` are co-located in `notification_model.dart`.

### Hive (local persistence)

Transaction and Category models use Hive CE (`hive_ce`) for offline storage.

**Critical rules:**
- Never change existing `@HiveType(typeId: N)` or `@HiveField(N)` indices — breaks existing stored data
- Register adapters in `main.dart` in typeId order before opening boxes
- After changing a Hive model, re-run build_runner to regenerate the adapter

### Linting

`very_good_analysis` ruleset. Common rules to watch:

- `avoid_types_on_closure_parameters` — use `(x) =>` not `(Type x) =>`
- `unnecessary_underscores` — use `_` not `__`/`___`
- `prefer_final_locals`, `require_trailing_commas`, `prefer_const_constructors`

Generated files (`*.freezed.dart`, `*.g.dart`, `*.gr.dart`) are excluded from analysis.

### Firebase / Backend

Firestore is the primary database. User-scoped path: `users/{uid}/...`.
`FirestoreService` and `FirebaseAuthService` in `lib/core/services/` are thin wrappers injected into repositories.

Image uploads → Cloudinary (`CloudinaryMediaService`). Keys from `.env`.

Logging: `AppLogger.info/warning/error` (`lib/core/utils/logger.dart`) — uses `logger` package, outputs to console.
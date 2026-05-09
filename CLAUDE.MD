# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run tests
flutter test

# Run a single test file
flutter test test/features/settings/settings_bloc_test.dart

# Lint
flutter analyze

# Code generation (freezed, injectable, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
flutter pub run build_runner watch --delete-conflicting-outputs
```

Localization (`.arb` files in `l10n/`) is auto-generated on `flutter pub get` / `flutter run` — no separate command needed.

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
4. Wrap app in `MultiRepositoryProvider` (exposes all repositories to the widget tree via `context.read<Repo>()`)
5. `SentryFlutter.init()` wraps `runApp`

### State Management

**BLoC pattern** throughout, using `bloc` / `flutter_bloc`:

- **BLoC** (event-driven) for complex flows: `AppBloc` (auth), `FavouritesBloc`, `NotificationsBloc`, `SettingsBloc`
- **Cubit** for simpler state: `HomeCubit`, `ScheduleCubit`, `BookingCubit`, `SubscriptionCubit`, `LocaleCubit`, `ProfileBloc`

**BLoC provision pattern:**
- **App-level** (`App` widget): `AppBloc`, `LocaleCubit`, `FavouritesBloc`
- **Shell-level** (`AppRouter` ShellRoute): `ScheduleCubit`, `BookingCubit`, `SubscriptionCubit`, `HomeCubit`, `NotificationsBloc`
- **Screen-level**: `ProfileBloc` (created in `ProfileTab`), `SettingsBloc` (created in `SettingsScreen`)

`AppBloc` holds the authenticated `UserModel` and drives auth-gated routing. Its state is read everywhere via `context.read<AppBloc>().state.user`.

### Navigation

GoRouter (`lib/core/router/app_router.dart`). Route constants are in `lib/core/router/route_names.dart`.

Route structure:
- `/` → SplashScreen
- `/login` → LoginScreen
- `/home` → ShellRoute with `AppShell` (bottom nav)
  - `/home/main` → HomeTab
  - `/home/programs` → ProgramsTab
  - `/home/schedule` → ScheduleTab
  - `/home/profile` → ProfileTab
- `/home/settings`, `/home/notifications`, `/home/history`, `/home/subscription` — standalone screens outside the shell

Navigate with `context.go(RouteNames.xxx)` or `context.push(RouteNames.xxx)`. All page transitions use a 200ms `FadeTransition`.

### Dependency Injection

GetIt + Injectable. All singletons are registered at startup via `configureDependencies()`, which calls into the generated `lib/di/injection.config.dart`.

Repositories are annotated `@lazySingleton`. Access them with `getIt<SomeRepository>()` (in router/non-widget code) or `context.read<SomeRepository>()` (in widgets, since `main.dart` wraps the tree in `MultiRepositoryProvider`).

After adding or changing an injectable class, re-run build_runner to regenerate `injection.config.dart`.

### Models

Models use **freezed** for immutable data classes and **json_serializable** for Firestore serialization. Most models also have a manual `fromJson` factory and a `toJson()` method alongside the generated code.

```dart
@freezed
abstract class SomeModel with _$SomeModel {
  const factory SomeModel({required String id, ...}) = _SomeModel;
  const SomeModel._(); // enables custom instance methods
  factory SomeModel.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
  static SomeModel get empty => const SomeModel(id: '', ...);
}
```

`NotificationItem` and `NotificationType` are defined inside `lib/data/models/notification_model.dart` alongside `NotificationModel`.

### Linting

`very_good_analysis` ruleset. Rules that come up most in practice:

- `avoid_types_on_closure_parameters` — don't annotate closure params (use `(x) =>` not `(Type x) =>`)
- `unnecessary_underscores` — use `_` not `__`/`___` for unused params
- `discarded_futures` — wrap fire-and-forget futures in `unawaited()`; for `FutureOr<void>` returns (e.g. Sentry), use `// ignore: discarded_futures` with a reason comment
- `prefer_final_locals`, `require_trailing_commas`, `prefer_const_constructors`

Generated files (`*.freezed.dart`, `*.g.dart`, `*.gr.dart`) are excluded from analysis.

### Firebase / Backend

Firestore is the primary database. User-scoped collections follow `users/{uid}/...`. `FirestoreService` and `FirebaseAuthService` in `lib/core/services/` are thin wrappers injected into repositories.

Image uploads go through Cloudinary (`CloudinaryMediaService`). Config keys come from `.env` via `flutter_dotenv`.

Logging and error reporting use `AppLogger.info/warning/error` (`lib/core/utils/logger.dart`), which wraps Sentry.

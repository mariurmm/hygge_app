import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:hygge_app/core/firebase/firebase_seed.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/features/app/ui/app.dart';

// Repositories
import 'package:hygge_app/data/repositories/auth_repository.dart';
import 'package:hygge_app/data/repositories/favourites_repository/favourites_repository.dart';
import 'package:hygge_app/data/repositories/favourites_repository/favourites_repository_impl.dart';
import 'package:hygge_app/data/repositories/notification_repository/notification_repository.dart';
import 'package:hygge_app/data/repositories/notification_repository/notification_repository_impl.dart';
import 'package:hygge_app/data/repositories/profile_about_repository/profile_about_repository.dart';
import 'package:hygge_app/data/repositories/profile_about_repository/profile_about_repository_impl.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository_impl.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository_impl.dart';
import 'package:hygge_app/data/repositories/user_repository/user_repository.dart';
import 'package:hygge_app/data/repositories/user_repository/user_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    AppLogger.info('main: .env загружен');
  } catch (_) {
    AppLogger.warning(
      'main: .env файл не найден — используем значения по умолчанию',
    );
  }

  await Firebase.initializeApp();
  AppLogger.info('main: Firebase инициализирован');

  // await FirebaseSeed.seedInitialData();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository.instance, // singleton
        ),
        RepositoryProvider<NotificationRepository>(
          create: (_) => NotificationRepositoryImpl(),
        ),
        RepositoryProvider<UserRepository>(create: (_) => UserRepositoryImpl()),
        RepositoryProvider<ProgramsRepository>(
          create: (_) => ProgramsRepositoryImpl(),
        ),
        RepositoryProvider<FavouritesRepository>(
          create: (_) => FavouritesRepositoryImpl(),
        ),
        RepositoryProvider<UpcomingLessonRepository>(
          create: (_) => UpcomingLessonRepositoryImpl(),
        ),
        RepositoryProvider<ProfileAboutRepository>(
          create: (_) => ProfileAboutRepositoryImpl(),
        ),
      ],
      child: const App(),
    ),
  );
}

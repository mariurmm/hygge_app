import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hygge_app/core/services/firestore_service.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/repositories/auth_repository.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/favourites_repository.dart';
import 'package:hygge_app/data/repositories/notification_repository.dart';
import 'package:hygge_app/data/repositories/profile_about_repository.dart';
import 'package:hygge_app/data/repositories/programs_repository.dart';
import 'package:hygge_app/data/repositories/schedule_repository.dart';
import 'package:hygge_app/data/repositories/subscription_repository.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository.dart';
import 'package:hygge_app/data/repositories/user_repository.dart';
import 'package:hygge_app/di/injection.dart';
import 'package:hygge_app/features/app/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    AppLogger.info('main: .env загружен');
  } on Exception catch (e, st) {
    AppLogger.warning(
      'main: .env файл не найден — используем значения по умолчанию',
    );
    AppLogger.error('main: dotenv error', error: e, stackTrace: st);
  }

  await Firebase.initializeApp();
  AppLogger.info('main: Firebase инициализирован');

  configureDependencies();

  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.instance.onTokenRefresh.listen(
    (token) {
      final authRepo = getIt<AuthRepository>();
      final user = authRepo.currentUser;
      if (user.isNotEmpty) {
        unawaited(
          getIt<FirestoreService>().saveUser(user.uid, {'fcmToken': token}),
        );
      }
    },
    onError: (Object e, StackTrace st) =>
        AppLogger.error('FCM onTokenRefresh error', error: e, stackTrace: st),
  );

  // await FirebaseSeed.seedInitialData();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => getIt<AuthRepository>(),
        ),
        RepositoryProvider<NotificationRepository>(
          create: (_) => getIt<NotificationRepository>(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => getIt<UserRepository>(),
        ),
        RepositoryProvider<ProgramsRepository>(
          create: (_) => getIt<ProgramsRepository>(),
        ),
        RepositoryProvider<FavouritesRepository>(
          create: (_) => getIt<FavouritesRepository>(),
        ),
        RepositoryProvider<UpcomingLessonRepository>(
          create: (_) => getIt<UpcomingLessonRepository>(),
        ),
        RepositoryProvider<ProfileAboutRepository>(
          create: (_) => getIt<ProfileAboutRepository>(),
        ),
        RepositoryProvider<ScheduleRepository>(
          create: (_) => getIt<ScheduleRepository>(),
        ),
        RepositoryProvider<BookingRepository>(
          create: (_) => getIt<BookingRepository>(),
        ),
        RepositoryProvider<SubscriptionRepository>(
          create: (_) => getIt<SubscriptionRepository>(),
        ),
      ],
      child: const App(),
    ),
  );
}

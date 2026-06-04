import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/localized_value.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/programs_repository.dart';
import 'package:hygge_app/di/injection.dart';
import 'package:hygge_app/features/home/bloc/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required BookingRepository bookingRepo,
    required String userId,
    ProgramsRepository? programsRepo,
    FirebaseFirestore? firestore,
  }) : _bookingRepo = bookingRepo,
       _userId = userId,
       _programsRepo = programsRepo ?? getIt<ProgramsRepository>(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(const HomeState()) {
    unawaited(loadUpcoming());
  }

  final BookingRepository _bookingRepo;
  final ProgramsRepository _programsRepo;
  final FirebaseFirestore _firestore;
  final String _userId;

  String _locale = LocalizedValue.defaultLocale;
  StreamSubscription<User?>? _authSub;

  Future<void> changeLocale(String locale) async {
    final normalizedLocale = _normalizeLocale(locale);
    if (_locale == normalizedLocale) return;
    _locale = normalizedLocale;
    await loadUpcoming();
  }

  Future<void> loadUpcoming() async {
    final uid = _userId.isNotEmpty
        ? _userId
        : getIt<FirebaseAuth>().currentUser?.uid ?? '';

    if (uid.isEmpty) {
      // userId not yet resolved — wait for first authenticated user
      await _authSub?.cancel();
      _authSub = getIt<FirebaseAuth>().authStateChanges().listen(
        (user) async {
          if (user != null) {
            await _authSub?.cancel();
            _authSub = null;
            unawaited(loadUpcoming());
          }
        },
      );
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final now = DateTime.now();
      final bookings = await _bookingRepo.getUpcomingBookings(uid);

      final lessons = <LessonModel>[];
      final seenProgramIds = <String>{};

      for (final booking in bookings) {
        final lesson = await _programsRepo.fetchLessonById(booking.classId);
        if (lesson == null || lesson.programId.isEmpty) continue;
        if (lesson.startDate.isBefore(now)) continue;
        if (!seenProgramIds.add(lesson.programId)) continue;
        lessons.add(lesson);
      }

      final programsById = <String, ProgramModel>{};
      for (final id in seenProgramIds) {
        final program = await _programsRepo.fetchProgramById(
          id,
          locale: _locale,
        );
        if (program != null) programsById[id] = program;
      }

      final mastersById = await _fetchMasters(
        programsById.values,
        locale: _locale,
      );

      emit(
        state.copyWith(
          lessons: lessons,
          programsById: programsById,
          mastersById: mastersById,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }

  Future<Map<String, MasterModel>> _fetchMasters(
    Iterable<ProgramModel> programs, {
    required String locale,
  }) async {
    final trainerIds = programs
        .map((program) => program.trainerId)
        .where((id) => id.isNotEmpty)
        .toSet();

    final result = <String, MasterModel>{};

    for (final trainerId in trainerIds) {
      final doc = await _firestore.collection('masters').doc(trainerId).get();
      final data = doc.data();
      if (!doc.exists || data == null) continue;
      result[trainerId] = MasterModel.fromJson(
        {...data, 'id': doc.id},
        locale: locale,
      );
    }

    return result;
  }

  String _normalizeLocale(String locale) {
    return switch (locale) {
      'en' => 'en',
      'kk' => 'kk',
      _ => LocalizedValue.defaultLocale,
    };
  }
}

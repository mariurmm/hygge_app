import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/core/utils/repository_executor.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

import 'programs_repository.dart';

class ProgramsRepositoryImpl
    with RepositoryExecutorMixin
    implements ProgramsRepository {
  ProgramsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _programs =>
      _firestore.collection('programs');

  @override
  Future<List<LessonModel>> fetchPrograms({int? limit}) => execute(
        actionName: 'ProgramsRepository.fetchPrograms',
        action: () async {
          Query<Map<String, dynamic>> query =
              _programs.where('isActive', isEqualTo: true);

          if (limit != null) query = query.limit(limit);

          final snapshot = await query.get();
          return snapshot.docs.map(_lessonFromDoc).toList();
        },
      );

  @override
  Stream<List<LessonModel>> watchPrograms({int? limit}) {
    Query<Map<String, dynamic>> query =
        _programs.where('isActive', isEqualTo: true);

    if (limit != null) query = query.limit(limit);

    return query
        .snapshots()
        .map((s) => s.docs.map(_lessonFromDoc).toList())
        .handleError(_onStreamError('ProgramsRepository.watchPrograms'));
  }

  @override
  Future<LessonModel?> fetchProgramById(String programId) => execute(
        actionName: 'ProgramsRepository.fetchProgramById',
        action: () async {
          if (programId.isEmpty) return null;

          final doc = await _programs.doc(programId).get();
          if (!doc.exists || doc.data() == null) return null;

          return _lessonFromDoc(doc);
        },
      );

  // ── Helpers ────────────────────────────────────────────────────────────────

  LessonModel _lessonFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return LessonModel.fromJson({...data, 'uuid': data['uuid'] ?? doc.id});
  }

  /// Converts stream errors to [Failure] subtypes for consistent handling.
  Function _onStreamError(String actionName) =>
      (Object error, StackTrace st) {
        logError(actionName, error, st);
        throw error;
      };
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/core/utils/repository_executor.dart';
import 'package:hygge_app/data/models/localized_value.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class ProgramsRepository with RepositoryExecutorMixin {
  ProgramsRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _programs =>
      _firestore.collection('programs');

  // ── Public API ────────────────────────────────────────────────

  Future<List<ProgramModel>> fetchPrograms({
    int? limit,
    String locale = LocalizedValue.defaultLocale,
  }) => execute(
    actionName: 'ProgramsRepository.fetchPrograms',
    action: () async {
      var query = _programs.where('isActive', isEqualTo: true);
      if (limit != null) query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => _programFromDoc(doc, locale: locale))
          .toList(growable: false);
    },
  );

  Stream<List<ProgramModel>> watchPrograms({
    int? limit,
    String locale = LocalizedValue.defaultLocale,
  }) {
    var query = _programs.where('isActive', isEqualTo: true);
    if (limit != null) query = query.limit(limit);

    return query
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => _programFromDoc(doc, locale: locale))
              .toList(growable: false);
        })
        .handleError(_onStreamError('ProgramsRepository.watchPrograms'));
  }

  Future<ProgramModel?> fetchProgramById(
    String programId, {
    String locale = LocalizedValue.defaultLocale,
  }) => execute(
    actionName: 'ProgramsRepository.fetchProgramById',
    action: () async {
      if (programId.trim().isEmpty) return null;

      final doc = await _programs.doc(programId).get();
      if (!doc.exists || doc.data() == null) return null;

      return _programFromDoc(doc, locale: locale);
    },
  );

  Future<List<ProgramModel>> fetchProgramsByMasterId(
    String masterId, {
    String locale = LocalizedValue.defaultLocale,
  }) => execute(
    actionName: 'ProgramsRepository.fetchProgramsByMasterId',
    action: () async {
      final normalizedMasterId = masterId.trim();
      if (normalizedMasterId.isEmpty) return const <ProgramModel>[];

      final snapshot = await _programs
          .where('isActive', isEqualTo: true)
          .where('masterId', isEqualTo: normalizedMasterId)
          .get();

      return snapshot.docs
          .map((doc) => _programFromDoc(doc, locale: locale))
          .toList(growable: false);
    },
  );

  // ── Helpers ──────────────────────────────────────────────────

  ProgramModel _programFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String locale,
  }) {
    final data = doc.data() ?? <String, dynamic>{};

    final program = ProgramModel.fromJson(
      {
        ...data,
        'uuid': data['uuid'] ?? doc.id,
      },
      locale: locale,
    );

    AppLogger.debug(
      'Program parsed: locale=$locale, '
      'rawTitle=${data['title']}, '
      'parsedTitle=${program.title}',
    );

    return program;
  }

  Function _onStreamError(String actionName) =>
      (Object error, StackTrace stackTrace) {
        logError(actionName, error, stackTrace);
        Error.throwWithStackTrace(error, stackTrace);
      };
}

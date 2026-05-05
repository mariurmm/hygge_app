import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/core/utils/repository_executor.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ProgramsRepository)
class ProgramsRepositoryImpl
    with RepositoryExecutorMixin
    implements ProgramsRepository {
  ProgramsRepositoryImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _programs =>
      _firestore.collection('programs');

  @override
  Future<List<ProgramModel>> fetchPrograms({int? limit}) => execute(
    actionName: 'ProgramsRepository.fetchPrograms',
    action: () async {
      var query = _programs.where('isActive', isEqualTo: true);
      if (limit != null) query = query.limit(limit);
      final snapshot = await query.get();
      return snapshot.docs.map(_programFromDoc).toList();
    },
  );

  @override
  Stream<List<ProgramModel>> watchPrograms({int? limit}) {
    var query = _programs.where('isActive', isEqualTo: true);
    if (limit != null) query = query.limit(limit);

    return query
        .snapshots()
        .map((s) => s.docs.map(_programFromDoc).toList())
        .handleError(_onStreamError('ProgramsRepository.watchPrograms'));
  }

  @override
  Future<ProgramModel?> fetchProgramById(String programId) => execute(
    actionName: 'ProgramsRepository.fetchProgramById',
    action: () async {
      if (programId.isEmpty) return null;
      final doc = await _programs.doc(programId).get();
      if (!doc.exists || doc.data() == null) return null;
      return _programFromDoc(doc);
    },
  );

  ProgramModel _programFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProgramModel.fromJson({...data, 'uuid': data['uuid'] ?? doc.id});
  }

  Function _onStreamError(String actionName) => (Object error, StackTrace st) {
    logError(actionName, error, st);
    Error.throwWithStackTrace(error, st);
  };
}

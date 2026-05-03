import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hygge_app/core/utils/repository_executor.dart';
import 'package:hygge_app/data/models/program_model.dart';

import 'favourites_repository.dart';

class FavouritesRepositoryImpl with RepositoryExecutorMixin implements FavouritesRepository {
  FavouritesRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _programs => _firestore.collection('programs');

  CollectionReference<Map<String, dynamic>> _favourites(String uid) =>
      _firestore.collection('users').doc(uid).collection('favourites');

  @override
  Stream<Set<String>> watchFavouriteIds() {
    final uid = _uid;
    if (uid == null) return Stream.value(<String>{});

    return _favourites(uid)
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toSet())
        .handleError(_onStreamError('FavouritesRepository.watchFavouriteIds'));
  }

  @override
  Future<Set<String>> fetchFavouriteIds() => execute(
    actionName: 'FavouritesRepository.fetchFavouriteIds',
    action: () async {
      final uid = _uid;
      if (uid == null) return <String>{};

      final snapshot = await _favourites(uid).get();
      return snapshot.docs.map((d) => d.id).toSet();
    },
  );

  @override
  Future<void> setFavourite({required String programId, required bool isFavourite}) => execute(
    actionName: 'FavouritesRepository.setFavourite',
    action: () async {
      final uid = _uid;
      if (uid == null || programId.isEmpty) return;

      final ref = _favourites(uid).doc(programId);

      if (isFavourite) {
        await ref.set({'programId': programId, 'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      } else {
        await ref.delete();
      }
    },
  );

  @override
  Future<List<ProgramModel>> fetchFavouritePrograms() => execute(
    actionName: 'FavouritesRepository.fetchFavouritePrograms',
    action: () async {
      final uid = _uid;
      if (uid == null) return const <ProgramModel>[];

      final snapshot = await _favourites(uid).get();
      final result = <ProgramModel>[];

      for (final doc in snapshot.docs) {
        final programDoc = await _programs.doc(doc.id).get();
        if (programDoc.exists && programDoc.data() != null) {
          result.add(_programFromDoc(programDoc));
        }
      }

      return result;
    },
  );

  // ── Helpers ────────────────────────────────────────────────────────────────

  ProgramModel _programFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProgramModel.fromJson({...data, 'uuid': data['uuid'] ?? doc.id});
  }

  Function _onStreamError(String actionName) =>
      (Object error, StackTrace st) => logError(actionName, error, st);
}

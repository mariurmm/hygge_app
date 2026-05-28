import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/core/utils/repository_executor.dart';
import 'package:hygge_app/data/models/profile_about_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class ProfileAboutRepository with RepositoryExecutorMixin {
  ProfileAboutRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const String _collection = 'app_content';
  static const String _document = 'profile_about';

  // ── Public API ────────────────────────────────────────────────

  Future<ProfileAboutModel> fetchProfileAbout({
    required String locale,
    required String userUid,
  }) => execute<ProfileAboutModel>(
    actionName: 'ProfileAboutRepository.fetchProfileAbout',
    action: () async {
      final doc = await _firestore.collection(_collection).doc(_document).get();

      if (!doc.exists || doc.data() == null) {
        return ProfileAboutModel.empty;
      }

      return ProfileAboutModel.fromJson(doc.data()!);
    },
  );
}

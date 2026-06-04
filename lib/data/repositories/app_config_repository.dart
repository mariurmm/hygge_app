import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/core/utils/repository_executor.dart';
import 'package:hygge_app/data/models/contact_info_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class AppConfigRepository with RepositoryExecutorMixin {
  AppConfigRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'app_content';
  static const String _document = 'profile_about';

  // ── Public API ────────────────────────────────────────────────

  Future<ContactInfoModel> getContactInfo(String languageCode) =>
      execute<ContactInfoModel>(
        actionName: 'AppConfigRepository.getContactInfo',
        action: () async {
          final doc = await _firestore
              .collection(_collection)
              .doc(_document)
              .get();

          if (!doc.exists || doc.data() == null) {
            return ContactInfoModel.fallback;
          }

          return ContactInfoModel.fromFirestore(doc.data()!, languageCode);
        },
      );
}

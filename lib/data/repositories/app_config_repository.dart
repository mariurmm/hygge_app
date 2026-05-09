import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/data/models/contact_info_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppConfigRepository {
  AppConfigRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<ContactInfoModel> getContactInfo(String languageCode) async {
    try {
      final doc = await _firestore
          .collection('app_content')
          .doc('profile_about')
          .get();
      return ContactInfoModel.fromFirestore(doc.data()!, languageCode);
    } on Exception catch (_) {
      return ContactInfoModel.fallback;
    }
  }
}

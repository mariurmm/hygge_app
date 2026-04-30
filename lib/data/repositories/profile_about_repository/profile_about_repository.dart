import 'package:hygge_app/data/models/profile_about_model.dart';

abstract class ProfileAboutRepository {
  Future<ProfileAboutModel> fetchProfileAbout({
    required String locale,
    required String userUid,
  });
}
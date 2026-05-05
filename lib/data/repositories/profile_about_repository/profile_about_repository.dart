import 'package:hygge_app/data/models/profile_about_model.dart';

// Abstract class kept for dependency injection — allows mocking in tests.
// ignore: one_member_abstracts
abstract class ProfileAboutRepository {
  Future<ProfileAboutModel> fetchProfileAbout({
    required String locale,
    required String userUid,
  });
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class UserRepository {
  UserRepository({required FirebaseAuth auth}) : _auth = auth;

  final FirebaseAuth _auth;

  // ── Public API ────────────────────────────────────────────────

  Future<UserModel> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return UserModel.empty;
    return UserModel.fromFirebaseUser(firebaseUser);
  }
}

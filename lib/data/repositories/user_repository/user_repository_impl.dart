import 'package:firebase_auth/firebase_auth.dart';
import 'package:hygge_app/data/models/user_model.dart';

import 'user_repository.dart';

/// Implementation of [UserRepository] using Firebase Auth.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<UserModel> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return UserModel.empty;
    return UserModel.fromFirebaseUser(firebaseUser);
  }
}

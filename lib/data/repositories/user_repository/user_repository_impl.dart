import 'package:firebase_auth/firebase_auth.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/data/repositories/user_repository/user_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required FirebaseAuth auth}) : _auth = auth;

  final FirebaseAuth _auth;

  @override
  Future<UserModel> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return UserModel.empty;
    return UserModel.fromFirebaseUser(firebaseUser);
  }
}

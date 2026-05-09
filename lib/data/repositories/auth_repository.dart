import 'package:hygge_app/core/services/firebase_auth_service.dart';
import 'package:hygge_app/core/services/firestore_service.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AuthRepository {
  AuthRepository({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  }) : _authService = authService,
       _firestoreService = firestoreService;

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  UserModel get currentUser {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) return UserModel.empty;
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  bool get isLoggedIn => _authService.currentUser != null;

  Stream<UserModel> get authStateChanges {
    return _authService.authStateChanges.map((firebaseUser) {
      if (firebaseUser == null) return UserModel.empty;
      return UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();

      if (credential?.user == null) return UserModel.empty;

      final user = UserModel.fromFirebaseUser(credential!.user!);

      await _firestoreService.saveUser(user.uid, user.toJson());

      AppLogger.info('AuthRepository: вход выполнен — ${user.email}');
      return user;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AuthRepository: ошибка входа через Google',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updateUserProfileFields({
    required String displayName,
    required String email,
  }) async {
    final fb = _authService.currentUser;
    if (fb == null) return;
    await _firestoreService.saveUser(fb.uid, {
      'uid': fb.uid,
      'displayName': displayName.trim(),
      'email': email.trim(),
    });
    final trimmed = displayName.trim();
    if (trimmed.isNotEmpty) {
      await fb.updateDisplayName(trimmed);
    }
  }

  Future<void> reloadCurrentUser() async {
    await _authService.currentUser?.reload();
  }

  Future<void> clearLocalCaches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> deleteAccount() async {
    final fb = _authService.currentUser;
    if (fb == null) {
      throw Exception('Пользователь не авторизован');
    }
    final uid = fb.uid;
    await _firestoreService.deleteUserDocument(uid);
    await _authService.deleteCurrentUser();
    try {
      await _authService.signOut();
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'AuthRepository: ошибка signOut при удалении аккаунта',
        error: error,
        stackTrace: stackTrace,
      );
    }
    await clearLocalCaches();
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      AppLogger.info('AuthRepository: пользователь вышел');
    } catch (error, stackTrace) {
      AppLogger.error(
        'AuthRepository: ошибка выхода',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

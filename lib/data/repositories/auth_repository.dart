import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hygge_app/core/services/firebase_auth_service.dart';
import 'package:hygge_app/core/services/firestore_service.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/core/utils/repository_executor.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton()
class AuthRepository with RepositoryExecutorMixin {
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

  Stream<UserModel> get authStateChanges =>
      _authService.authStateChanges.map((firebaseUser) {
        if (firebaseUser == null) return UserModel.empty;
        return UserModel.fromFirebaseUser(firebaseUser);
      });

  Future<UserModel> signInWithGoogle() => execute(
    actionName: 'AuthRepository.signInWithGoogle',
    action: () async {
      final credential = await _authService.signInWithGoogle();
      if (credential?.user == null) return UserModel.empty;

      final user = UserModel.fromFirebaseUser(credential!.user!);
      await _firestoreService.saveUser(user.uid, user.toJson());
      unawaited(_saveFcmToken(user.uid));
      return user;
    },
  );

  Future<void> _saveFcmToken(String userId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _firestoreService.saveUser(userId, {'fcmToken': token});
      AppLogger.info('AuthRepository: FCM токен сохранён для $userId');
    } on Object catch (e) {
      AppLogger.warning('AuthRepository: не удалось сохранить FCM токен — $e');
    }
  }

  Future<void> updateUserProfileFields({
    required String displayName,
    required String email,
  }) => execute(
    actionName: 'AuthRepository.updateUserProfileFields',
    action: () async {
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
    },
  );

  Future<void> reloadCurrentUser() => execute(
    actionName: 'AuthRepository.reloadCurrentUser',
    action: () async {
      await _authService.currentUser?.reload();
    },
  );

  Future<void> clearLocalCaches() => execute(
    actionName: 'AuthRepository.clearLocalCaches',
    action: () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    },
  );

  Future<void> deleteAccount() => execute(
    actionName: 'AuthRepository.deleteAccount',
    action: () async {
      final fb = _authService.currentUser;
      if (fb == null) {
        throw Exception('Пользователь не авторизован');
      }

      final uid = fb.uid;
      await _firestoreService.deleteUserDocument(uid);
      await _authService.deleteCurrentUser();
      await _authService.signOut();
      await clearLocalCaches();
    },
  );

  Future<void> signOut() => execute(
    actionName: 'AuthRepository.signOut',
    action: () async {
      await _authService.signOut();
    },
  );
}

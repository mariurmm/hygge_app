import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hygge_app/core/utils/failure.dart';
import 'package:hygge_app/core/utils/logger.dart';

/// Mixin that decouples repository implementations from the boilerplate of
/// try/catch + logging + error mapping.
///
/// Usage:
/// ```dart
/// class UserRepositoryImpl
///     with RepositoryExecutorMixin
///     implements UserRepository {
///   @override
///   Future<UserEntity> getUser(String id) => execute(
///         action: () async {
///           final snapshot =
///               await _firestore.collection('users').doc(id).get();
///           if (!snapshot.exists) {
///             throw const NotFoundFailure(message: 'User not found');
///           }
///           return UserModel.fromFirestore(snapshot).toEntity();
///         },
///         actionName: 'UserRepository.getUser',
///       );
/// }
/// ```
mixin RepositoryExecutorMixin {
  /// Override in the concrete repository to plug in your logger.
  @protected
  void logError(String actionName, Object error, StackTrace stackTrace) {
    AppLogger.error(
      '[$runtimeType] $actionName failed',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Wraps an async [action], logs any exception and rethrows it as a
  /// [Failure] subtype that the domain layer can pattern-match on.
  ///
  /// [actionName] is used purely for log readability — pass something like
  /// `'UserRepository.getUser'`.
  @protected
  Future<T> execute<T>({
    required Future<T> Function() action,
    required String actionName,
  }) async {
    try {
      return await action();
    } on Failure {
      rethrow;
    } on FirebaseAuthException catch (e, st) {
      logError(actionName, e, st);
      throw _mapAuthException(e, st);
    } on FirebaseException catch (e, st) {
      logError(actionName, e, st);
      throw _mapFirebaseException(e, st);
    } on SocketException catch (e, st) {
      logError(actionName, e, st);
      throw NetworkFailure(
        message: 'No internet connection',
        cause: e,
        stackTrace: st,
      );
    } on TimeoutException catch (e, st) {
      logError(actionName, e, st);
      throw NetworkFailure(
        message: 'Request timed out',
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      logError(actionName, e, st);
      throw UnknownFailure(message: e.toString(), cause: e, stackTrace: st);
    }
  }

  // ---------------------------------------------------------------------------
  // Mapping helpers
  // ---------------------------------------------------------------------------

  Failure _mapAuthException(FirebaseAuthException e, StackTrace st) {
    return AuthFailure(
      message: e.message ?? 'Authentication error',
      code: e.code,
      cause: e,
      stackTrace: st,
    );
  }

  Failure _mapFirebaseException(FirebaseException e, StackTrace st) {
    return switch (e.code) {
      'permission-denied' => PermissionFailure(
        message: e.message ?? 'Permission denied',
        code: e.code,
        cause: e,
        stackTrace: st,
      ),
      'not-found' => NotFoundFailure(
        message: e.message ?? 'Document not found',
        code: e.code,
        cause: e,
        stackTrace: st,
      ),
      'unavailable' || 'deadline-exceeded' => NetworkFailure(
        message: e.message ?? 'Service unavailable',
        code: e.code,
        cause: e,
        stackTrace: st,
      ),
      _ => ServerFailure(
        message: e.message ?? 'Server error',
        code: e.code,
        cause: e,
        stackTrace: st,
      ),
    };
  }
}

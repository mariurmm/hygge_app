import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hygge_app/data/models/subscription_model.dart';

/// Модель пользователя.
class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    this.subscription,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      subscription: json['subscription'] is Map
          ? SubscriptionModel.fromJson(
              Map<String, dynamic>.from(json['subscription'] as Map),
            )
          : null,
    );
  }

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }

  /// Уникальный идентификатор (совпадает с uid в FirebaseAuth).
  final String uid;

  /// Отображаемое имя.
  final String displayName;

  /// Email пользователя.
  final String email;

  /// URL аватара.
  final String photoUrl;

  /// Активный абонемент пользователя.
  final SubscriptionModel? subscription;

  static const UserModel empty = UserModel(
    uid: '',
    displayName: '',
    email: '',
    photoUrl: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'subscription': subscription?.toJson(),
    };
  }

  @override
  List<Object?> get props => [uid, displayName, email, photoUrl, subscription];
}

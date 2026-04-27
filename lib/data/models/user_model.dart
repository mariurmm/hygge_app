import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'subscription_model.dart';

/// Модель пользователя.
class UserModel extends Equatable {
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

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    this.subscription,
  });

  static const UserModel empty = UserModel(
    uid: '',
    displayName: '',
    email: '',
    photoUrl: '',
    subscription: null,
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    String locale = 'ru',
  }) {
    return UserModel(
      uid: json['uid'] as String? ?? json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      subscription: json['subscription'] is Map
          ? SubscriptionModel.fromJson(
              Map<String, dynamic>.from(json['subscription'] as Map),
              locale: locale,
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
      subscription: null,
    );
  }

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

import 'package:equatable/equatable.dart';

import 'package:hygge_app/data/models/localized_value.dart';

/// Модель мастера.
class MasterModel extends Equatable {
  const MasterModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.bio = '',
    this.photoUrl = '',
  });

  factory MasterModel.fromJson(
    Map<String, dynamic> json, {
    String locale = LocalizedValue.defaultLocale,
  }) {
    return MasterModel(
      id: json['uuid'] as String? ?? json['id'] as String? ?? '',
      firstName: LocalizedValue.read(json['firstName'], locale: locale),
      lastName: LocalizedValue.read(json['lastName'], locale: locale),
      bio: LocalizedValue.read(json['bio'], locale: locale),
      photoUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  /// Уникальный идентификатор.
  final String id;

  /// Имя.
  final String firstName;

  /// Фамилия.
  final String lastName;

  /// Описание / биография мастера.
  final String bio;

  /// URL фото мастера.
  final String photoUrl;

  /// Пустая модель.
  static const MasterModel empty = MasterModel(
    id: '',
    firstName: '',
    lastName: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  /// Полное имя.
  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'avatarUrl': photoUrl,
    };
  }

  @override
  List<Object?> get props => [id, firstName, lastName, bio, photoUrl];
}

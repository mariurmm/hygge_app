import 'package:equatable/equatable.dart';

import 'localized_value.dart';

/// Модель мастера.
class MasterModel extends Equatable {
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

  const MasterModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.bio = '',
    this.photoUrl = '',
  });

  /// Пустая модель.
  static const MasterModel empty = MasterModel(id: '', firstName: '', lastName: '', bio: '', photoUrl: '');

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  /// Полное имя.
  String get fullName => '$firstName $lastName'.trim();

  factory MasterModel.fromJson(Map<String, dynamic> json, {String locale = LocalizedValue.defaultLocale}) {
    return MasterModel(
      id: json['uuid'] as String? ?? json['id'] as String? ?? '',
      firstName: LocalizedValue.read(json['firstName'], locale: locale),
      lastName: LocalizedValue.read(json['lastName'], locale: locale),
      bio: LocalizedValue.read(json['bio'], locale: locale),
      photoUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'uuid': id, 'firstName': firstName, 'lastName': lastName, 'bio': bio, 'avatarUrl': photoUrl};
  }

  @override
  List<Object?> get props => [id, firstName, lastName, bio, photoUrl];
}

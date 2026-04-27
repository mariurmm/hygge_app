import 'package:equatable/equatable.dart';

import 'localized_value.dart';

/// Модель мастера.
class MasterModel extends Equatable {
  /// Уникальный идентификатор.
  final String uuid;

  /// Имя.
  final String firstName;

  /// Фамилия.
  final String lastName;

  /// Описание / биография мастера.
  final String bio;

  /// URL аватара мастера.
  final String avatarUrl;

  const MasterModel({
    required this.uuid,
    required this.firstName,
    required this.lastName,
    this.bio = '',
    this.avatarUrl = '',
  });

  /// Пустая модель.
  static const MasterModel empty = MasterModel(
    uuid: '',
    firstName: '',
    lastName: '',
    bio: '',
    avatarUrl: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  /// Полное имя.
  String get fullName => '$firstName $lastName'.trim();

  factory MasterModel.fromJson(
    Map<String, dynamic> json, {
    String locale = LocalizedValue.defaultLocale,
  }) {
    return MasterModel(
      uuid: json['uuid'] as String? ?? json['id'] as String? ?? '',
      firstName: LocalizedValue.read(json['firstName'], locale: locale),
      lastName: LocalizedValue.read(json['lastName'], locale: locale),
      bio: LocalizedValue.read(json['bio'], locale: locale),
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'avatarUrl': avatarUrl,
    };
  }

  @override
  List<Object?> get props => [uuid, firstName, lastName, bio, avatarUrl];
}

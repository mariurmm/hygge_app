import 'package:equatable/equatable.dart';

/// Модель мастера.
class MasterModel extends Equatable {
  /// Уникальный идентификатор.
  final String uuid;

  /// Имя.
  final String firstName;

  /// Фамилия.
  final String lastName;

  const MasterModel({
    required this.uuid,
    required this.firstName,
    required this.lastName,
  });

  /// Пустая модель.
  static const MasterModel empty = MasterModel(
    uuid: '',
    firstName: '',
    lastName: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  /// Полное имя.
  String get fullName => '$firstName $lastName'.trim();

  factory MasterModel.fromJson(Map<String, dynamic> json) {
    return MasterModel(
      uuid: json['uuid'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  @override
  List<Object?> get props => [uuid, firstName, lastName];
}

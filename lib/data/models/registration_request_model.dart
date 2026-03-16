import 'package:equatable/equatable.dart';

/// Модель запроса на регистрацию.
class RegistrationRequestModel extends Equatable {
  /// Имя пользователя.
  final String firstName;

  /// Фамилия пользователя.
  final String lastName;

  /// Email пользователя.
  final String email;

  /// Пароль пользователя.
  final String password;

  const RegistrationRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  /// Пустая модель.
  static const RegistrationRequestModel empty = RegistrationRequestModel(
    firstName: '',
    lastName: '',
    email: '',
    password: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  factory RegistrationRequestModel.fromJson(Map<String, dynamic> json) {
    return RegistrationRequestModel(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    };
  }

  @override
  List<Object?> get props => [firstName, lastName, email, password];
}

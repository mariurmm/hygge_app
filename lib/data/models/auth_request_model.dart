import 'package:equatable/equatable.dart';

/// Модель запроса на авторизацию.
class AuthRequestModel extends Equatable {
  /// Email пользователя.
  final String email;

  /// Пароль пользователя.
  final String password;

  const AuthRequestModel({
    required this.email,
    required this.password,
  });

  /// Пустая модель.
  static const AuthRequestModel empty = AuthRequestModel(
    email: '',
    password: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  factory AuthRequestModel.fromJson(Map<String, dynamic> json) {
    return AuthRequestModel(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  List<Object?> get props => [email, password];
}

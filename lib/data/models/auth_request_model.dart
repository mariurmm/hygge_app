import 'package:equatable/equatable.dart';

/// Модель запроса на авторизацию.
class AuthRequestModel extends Equatable {
  const AuthRequestModel({required this.email, required this.password});

  factory AuthRequestModel.fromJson(Map<String, dynamic> json) {
    return AuthRequestModel(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  /// Email пользователя.
  final String email;

  /// Пароль пользователя.
  final String password;

  /// Пустая модель.
  static const AuthRequestModel empty = AuthRequestModel(
    email: '',
    password: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  @override
  List<Object?> get props => [email, password];
}

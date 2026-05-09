import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_request_model.freezed.dart';
part 'auth_request_model.g.dart';

@freezed
abstract class AuthRequestModel with _$AuthRequestModel {
  const factory AuthRequestModel({
    @Default('') String email,
    @Default('') String password,
  }) = _AuthRequestModel;

  const AuthRequestModel._();

  factory AuthRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AuthRequestModelFromJson(json);

  static const AuthRequestModel empty = AuthRequestModel();

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;
}

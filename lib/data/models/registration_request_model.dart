import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_request_model.freezed.dart';
part 'registration_request_model.g.dart';

@freezed
abstract class RegistrationRequestModel with _$RegistrationRequestModel {
  const factory RegistrationRequestModel({
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String email,
    @Default('') String password,
  }) = _RegistrationRequestModel;

  const RegistrationRequestModel._();

  factory RegistrationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegistrationRequestModelFromJson(json);

  static const RegistrationRequestModel empty = RegistrationRequestModel();

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;
}

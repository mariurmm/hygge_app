import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:hygge_app/data/models/localized_value.dart';

part 'master_model.freezed.dart';

@freezed
abstract class MasterModel with _$MasterModel {
  const factory MasterModel({
    required String id,
    required String firstName,
    required String lastName,
    @Default('') String bio,
    @Default('') String photoUrl,
  }) = _MasterModel;

  const MasterModel._();

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

  static const MasterModel empty = MasterModel(
    id: '',
    firstName: '',
    lastName: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

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
}

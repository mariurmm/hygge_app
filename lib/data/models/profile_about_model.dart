import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_about_model.freezed.dart';
part 'profile_about_model.g.dart';

/// Represents the "About" / company profile content fetched from Firestore.
///
/// All fields default to empty string so callers never need to null-check.
///
/// ### Firestore document shape (`app_content/profile_about`)
/// ```json
/// {
///   "companyName" : "Hygge",
///   "description" : "...",
///   "address"     : "...",
///   "phone"       : "+7 777 000 00 00",
///   "email"       : "hello@hygge.app",
///   "website"     : "https://hygge.app",
///   "instagram"   : "https://instagram.com/hygge",
///   "facebook"    : "https://facebook.com/hygge",
///   "telegram"    : "https://t.me/hygge",
///   "whatsapp"    : "https://wa.me/77770000000",
///   "youTube"     : "https://youtube.com/@hygge",
///   "workingHours": "Mon–Fri 9:00–18:00"
/// }
/// ```
@freezed
abstract class ProfileAboutModel with _$ProfileAboutModel {
  const factory ProfileAboutModel({
    @Default('') String companyName,
    @Default('') String description,
    @Default('') String address,
    @Default('') String phone,
    @Default('') String email,
    @Default('') String website,
    @Default('') String instagram,
    @Default('') String facebook,
    @Default('') String telegram,
    @Default('') String whatsapp,
    @Default('') String youTube,
    @Default('') String workingHours,
  }) = _ProfileAboutModel;
  const ProfileAboutModel._();

  factory ProfileAboutModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileAboutModelFromJson(json);

  static const ProfileAboutModel empty = ProfileAboutModel();

  bool get isEmpty =>
      companyName.isEmpty &&
      description.isEmpty &&
      address.isEmpty &&
      phone.isEmpty &&
      email.isEmpty;
}

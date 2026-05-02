/// Represents the "About" / company profile content fetched from Firestore.
///
/// This is a pure data model — no locale resolution.
/// All UI labels come from ARB files; this model carries only raw values.
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
class ProfileAboutModel {
  const ProfileAboutModel({
    required this.companyName,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.instagram,
    required this.facebook,
    required this.telegram,
    required this.whatsapp,
    required this.youTube,
    required this.workingHours,
  });

  final String companyName;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String instagram;
  final String facebook;
  final String telegram;
  final String whatsapp;
  final String youTube;
  final String workingHours;

  // ── Derived ───────────────────────────────────────────────────────────────

  bool get isEmpty =>
      companyName.isEmpty &&
      description.isEmpty &&
      address.isEmpty &&
      phone.isEmpty &&
      email.isEmpty;

  // ── Factories ─────────────────────────────────────────────────────────────

  factory ProfileAboutModel.fromJson(Map<String, dynamic> json) {
    String str(String key) {
      final value = json[key];
      return value is String ? value : '';
    }

    return ProfileAboutModel(
      companyName:  str('companyName'),
      description:  str('description'),
      address:      str('address'),
      workingHours: str('workingHours'),
      phone:        str('phone'),
      email:        str('email'),
      website:      str('website'),
      instagram:    str('instagram'),
      facebook:     str('facebook'),
      telegram:     str('telegram'),
      whatsapp:     str('whatsapp'),
      youTube:      str('youTube'),
    );
  }

  static const ProfileAboutModel empty = ProfileAboutModel(
    companyName:  '',
    description:  '',
    address:      '',
    workingHours: '',
    phone:        '',
    email:        '',
    website:      '',
    instagram:    '',
    facebook:     '',
    telegram:     '',
    whatsapp:     '',
    youTube:      '',
  );

  // ── copyWith ──────────────────────────────────────────────────────────────

  ProfileAboutModel copyWith({
    String? companyName,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? instagram,
    String? facebook,
    String? telegram,
    String? whatsapp,
    String? youTube,
    String? workingHours,
  }) {
    return ProfileAboutModel(
      companyName:  companyName  ?? this.companyName,
      description:  description  ?? this.description,
      address:      address      ?? this.address,
      phone:        phone        ?? this.phone,
      email:        email        ?? this.email,
      website:      website      ?? this.website,
      instagram:    instagram    ?? this.instagram,
      facebook:     facebook     ?? this.facebook,
      telegram:     telegram     ?? this.telegram,
      whatsapp:     whatsapp     ?? this.whatsapp,
      youTube:      youTube      ?? this.youTube,
      workingHours: workingHours ?? this.workingHours,
    );
  }

  // ── Equality & debugging ──────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAboutModel &&
          companyName  == other.companyName  &&
          description  == other.description  &&
          address      == other.address      &&
          phone        == other.phone        &&
          email        == other.email        &&
          website      == other.website      &&
          instagram    == other.instagram    &&
          facebook     == other.facebook     &&
          telegram     == other.telegram     &&
          whatsapp     == other.whatsapp     &&
          youTube      == other.youTube      &&
          workingHours == other.workingHours;

  @override
  int get hashCode => Object.hashAll([
        companyName,  description,  address,
        phone,        email,        website,
        instagram,    facebook,     telegram,
        whatsapp,     youTube,      workingHours,
      ]);

  @override
  String toString() => 'ProfileAboutModel('
      'companyName: $companyName, '
      'email: $email, '
      'phone: $phone)';
}
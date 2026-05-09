class ContactInfoModel {
  const ContactInfoModel({
    required this.phoneDisplay,
    required this.phoneUri,
    required this.email,
    required this.emailUri,
    required this.instagramConceptLabel,
    required this.instagramConceptUrl,
    required this.instagramBarLabel,
    required this.instagramBarUrl,
    required this.mapAddress,
    required this.mapUrl,
    required this.title,
  });

  factory ContactInfoModel.fromFirestore(
    Map<String, dynamic> data,
    String languageCode,
  ) {
    String localized(dynamic field) {
      if (field is Map) {
        return (field[languageCode] ?? field['en'] ?? '') as String;
      }
      return field as String? ?? '';
    }

    return ContactInfoModel(
      phoneDisplay: localized(data['phoneDisplay']),
      phoneUri: localized(data['phoneUri']),
      email: localized(data['email']),
      emailUri: localized(data['emailUri']),
      instagramConceptLabel: localized(data['instagramConceptLabel']),
      instagramConceptUrl: localized(data['instagramConceptUrl']),
      instagramBarLabel: localized(data['instagramBarLabel']),
      instagramBarUrl: localized(data['instagramBarUrl']),
      mapAddress: localized(data['mapAddress']),
      mapUrl: localized(data['mapUrl']),
      title: localized(data['title']),
    );
  }

  final String phoneDisplay;
  final String phoneUri;
  final String email;
  final String emailUri;
  final String instagramConceptLabel;
  final String instagramConceptUrl;
  final String instagramBarLabel;
  final String instagramBarUrl;
  final String mapAddress;
  final String mapUrl;
  final String title;

  static const fallback = ContactInfoModel(
    phoneDisplay: 'xxx',//+7 777 000 00 00
    phoneUri: 'xxx',//tel:+77770000000
    email: 'xxx',//hy.gge_concept@gmail.com
    emailUri: 'xxx',//mailto:hy.gge_concept@gmail.com
    instagramConceptLabel: 'xxx',//@hy.gge_concept
    instagramConceptUrl: 'xxx',//https://instagram.com/hy.gge.concept
    instagramBarLabel: 'xxx',//@hy.gge.specialty.bar
    instagramBarUrl: 'xxx',//https://instagram.com/hy.gge.specialty.bar/
    mapAddress: 'xxx',//Казахстан, Алматы, ул. Зенкова, 17
    mapUrl: 'xxx',//https://maps.app.goo.gl/4bk3WANmFhNcCwXF7
    title: 'xxx',//О нас
  );
}

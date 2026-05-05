/// Хелпер для чтения локализованных полей из Firestore.
///
/// Поддерживает два формата:
/// 1) String: "Утренняя йога"
/// 2) Map: {"en": "Morning Yoga", "ru": "Утренняя йога", "kk": "Таңғы йога"}
class LocalizedValue {
  const LocalizedValue._();

  static const String defaultLocale = 'ru';

  static String read(
    dynamic value, {
    String locale = defaultLocale,
    String fallbackLocale = 'en',
  }) {
    if (value == null) return '';

    if (value is String) return value;

    if (value is Map) {
      final localized = value[locale];
      if (localized is String && localized.isNotEmpty) return localized;

      final fallback = value[fallbackLocale];
      if (fallback is String && fallback.isNotEmpty) return fallback;

      final ru = value['ru'];
      if (ru is String && ru.isNotEmpty) return ru;

      final en = value['en'];
      if (en is String && en.isNotEmpty) return en;

      final kk = value['kk'];
      if (kk is String && kk.isNotEmpty) return kk;
    }

    return '';
  }

  static Map<String, String> write({
    required String en,
    required String ru,
    required String kk,
  }) {
    return {'en': en, 'ru': ru, 'kk': kk};
  }
}

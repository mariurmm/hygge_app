import 'package:cloud_firestore/cloud_firestore.dart';

final class FirebaseSeed {
  FirebaseSeed._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedInitialData() async {
    final WriteBatch batch = _firestore.batch();

    _seedMasters(batch);
    _seedPrograms(batch);
    _seedLessons(batch);

    await batch.commit();
  }

  static void _seedMasters(WriteBatch batch) {
    const String masterId = 'aigerim_amantaeva_001';

    final DocumentReference<Map<String, dynamic>> ref = _firestore.collection('masters').doc(masterId);

    batch.set(ref, {
      'uuid': masterId,
      'firstName': {'ru': 'Айгерим', 'en': 'Aigerim', 'kk': 'Айгерім'},
      'lastName': {'ru': 'Амантаева', 'en': 'Amantaeva', 'kk': 'Амантаева'},
      'bio': {
        'ru':
            'Айгерим Амантаева — со-основатель Hygge Concept и сертифицированный преподаватель Хатха-йоги и Аштанга-виньясы. Обучалась в Институте Йоги «Pradnaya» по программе Yoga Vidya Gurukul, India; Boston Yoga Union, Massachusetts, USA; Lino Miele Workshop, Kerala, India.',
        'en':
            'Aigerim Amantaeva is a co-founder of Hygge Concept and a certified Hatha Yoga and Ashtanga Vinyasa teacher. She studied at the Pradnaya Yoga Institute under the Yoga Vidya Gurukul program in India, Boston Yoga Union in Massachusetts, USA, and the Lino Miele Workshop in Kerala, India.',
        'kk':
            'Айгерім Амантаева — Hygge Concept жобасының тең құрылтайшысы және Хатха-йога мен Аштанга виньяса бойынша сертификатталған нұсқаушы. Ол Үндістандағы Yoga Vidya Gurukul бағдарламасы бойынша «Pradnaya» Йога институтында, АҚШ-тың Массачусетс штатындағы Boston Yoga Union орталығында және Үндістанның Керала штатындағы Lino Miele Workshop бағдарламасында білім алған.',
      },
      'avatarUrl': 'https://res.cloudinary.com/dl04teduu/image/upload/PASTE_AIGERIM_AVATAR_URL.jpg',
    });
  }

  static void _seedPrograms(WriteBatch batch) {
    const String programId = 'hatha_yoga_aigerim_001';
    const String masterId = 'aigerim_amantaeva_001';

    final DocumentReference<Map<String, dynamic>> ref = _firestore.collection('programs').doc(programId);

    batch.set(ref, {
      'uuid': programId,
      'category': 'yoga',
      'masterId': masterId,
      'price': 3500,
      'isActive': true,
      'isBookable': true,
      'imageUrl': 'https://res.cloudinary.com/dl04teduu/image/upload/PASTE_HATHA_YOGA_IMAGE_URL.jpg',
      'ritual': {
        'ru': 'Практика осознанного движения',
        'en': 'Mindful Movement Practice',
        'kk': 'Саналы қозғалыс тәжірибесі',
      },
      'title': {'ru': 'Хатха-йога с Айгерим', 'en': 'Hatha Yoga with Aigerim', 'kk': 'Айгеріммен Хатха-йога'},
      'text': {
        'ru':
            'Сбалансированная программа Хатха-йоги для развития гибкости, устойчивости, дыхания и внутренней концентрации. Подходит для тех, кто хочет мягко войти в практику и укрепить тело через осознанное движение.',
        'en':
            'A balanced Hatha Yoga program focused on flexibility, stability, breathing, and inner concentration. Suitable for those who want to enter the practice gently and strengthen the body through mindful movement.',
        'kk':
            'Икемділікті, тұрақтылықты, тыныс алуды және ішкі зейінді дамытуға бағытталған теңгерімді Хатха-йога бағдарламасы. Тәжірибеге жұмсақ кірісіп, саналы қозғалыс арқылы денені нығайтқысы келетіндерге қолайлы.',
      },
    });
  }

  static void _seedLessons(WriteBatch batch) {
    const String programId = 'hatha_yoga_aigerim_001';
    const String masterId = 'aigerim_amantaeva_001';

    final List<Map<String, dynamic>> lessons = <Map<String, dynamic>>[
      {
        'uuid': 'hatha_yoga_aigerim_001_2026_05_05_0800',
        'programId': programId,
        'masterId': masterId,
        'startDate': Timestamp.fromDate(DateTime(2026, 5, 5, 8)),
        'finishDate': Timestamp.fromDate(DateTime(2026, 5, 5, 9)),
        'isBookable': true,
      },
      {
        'uuid': 'hatha_yoga_aigerim_001_2026_05_07_0800',
        'programId': programId,
        'masterId': masterId,
        'startDate': Timestamp.fromDate(DateTime(2026, 5, 7, 8)),
        'finishDate': Timestamp.fromDate(DateTime(2026, 5, 7, 9)),
        'isBookable': true,
      },
      {
        'uuid': 'hatha_yoga_aigerim_001_2026_05_09_1000',
        'programId': programId,
        'masterId': masterId,
        'startDate': Timestamp.fromDate(DateTime(2026, 5, 9, 10)),
        'finishDate': Timestamp.fromDate(DateTime(2026, 5, 9, 11)),
        'isBookable': true,
      },
    ];

    for (final Map<String, dynamic> lesson in lessons) {
      final String lessonId = lesson['uuid'] as String;

      final DocumentReference<Map<String, dynamic>> ref = _firestore.collection('lessons').doc(lessonId);

      batch.set(ref, lesson);
    }
  }
}

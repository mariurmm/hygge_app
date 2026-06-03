import 'package:cloud_firestore/cloud_firestore.dart';

final class FirebaseSeed {
  FirebaseSeed._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedInitialData() async {
    final batch = _firestore.batch();

    _seedMasters(batch);
    _seedPrograms(batch);
    _seedLessons(batch);
    _seedClasses(batch);

    await batch.commit();
  }

  static void _seedMasters(WriteBatch batch) {
    const aigerimId = 'aigerim_amantaeva_001';
    const danaId = 'dana_sadykova_001';
    const armanId = 'arman_ibrayev_001';

    batch
      ..set(_firestore.collection('masters').doc(aigerimId), {
        'uuid': aigerimId,
        'firstName': {'ru': 'Айгерим', 'en': 'Aigerim', 'kk': 'Айгерім'},
        'lastName': {'ru': 'Амантаева', 'en': 'Amantaeva', 'kk': 'Амантаева'},
        'bio': {
          'ru':
              'Айгерим Амантаева — со-основатель Hygge Concept и '
              'сертифицированный преподаватель Хатха-йоги и Аштанга-виньясы. '
              'Обучалась в Институте Йоги «Pradnaya» по программе Yoga Vidya '
              'Gurukul, India; Boston Yoga Union, Massachusetts, USA; '
              'Lino Miele Workshop, Kerala, India.',
          'en':
              'Aigerim Amantaeva is a co-founder of Hygge Concept and a '
              'certified Hatha Yoga and Ashtanga Vinyasa teacher. She studied '
              'at the Pradnaya Yoga Institute under the Yoga Vidya Gurukul '
              'program in India, Boston Yoga Union in Massachusetts, USA, and '
              'the Lino Miele Workshop in Kerala, India.',
          'kk':
              'Айгерім Амантаева — Hygge Concept жобасының тең құрылтайшысы '
              'және Хатха-йога мен Аштанга виньяса бойынша сертификатталған '
              'нұсқаушы. Ол Үндістандағы Yoga Vidya Gurukul бағдарламасы '
              'бойынша «Pradnaya» Йога институтында, АҚШ-тың Массачусетс '
              'штатындағы Boston Yoga Union орталығында және Үндістанның '
              'Керала штатындағы Lino Miele Workshop бағдарламасында '
              'білім алған.',
        },
        'avatarUrl':
            'https://res.cloudinary.com/dl04teduu/image/upload/PASTE_AIGERIM_AVATAR_URL.jpg',
      })
      ..set(_firestore.collection('masters').doc(danaId), {
        'uuid': danaId,
        'firstName': {'ru': 'Дана', 'en': 'Dana', 'kk': 'Дана'},
        'lastName': {'ru': 'Садыкова', 'en': 'Sadykova', 'kk': 'Садықова'},
        'bio': {
          'ru':
              'Дана Садыкова — инструктор по медитации, дыхательным практикам '
              'и мягкой телесной терапии. Работает с восстановлением внимания, '
              'регуляцией стресса и практиками внутреннего спокойствия.',
          'en':
              'Dana Sadykova is a meditation, breathwork, and soft body therapy '
              'instructor. Her work focuses on attention recovery, stress '
              'regulation, and inner calm practices.',
          'kk':
              'Дана Садықова — медитация, тыныс алу тәжірибелері және жұмсақ '
              'дене терапиясы бойынша нұсқаушы. Оның жұмысы зейінді қалпына '
              'келтіруге, күйзелісті реттеуге және ішкі тыныштыққа бағытталған.',
        },
        'avatarUrl':
            'https://res.cloudinary.com/dl04teduu/image/upload/PASTE_DANA_AVATAR_URL.jpg',
      })
      ..set(_firestore.collection('masters').doc(armanId), {
        'uuid': armanId,
        'firstName': {'ru': 'Арман', 'en': 'Arman', 'kk': 'Арман'},
        'lastName': {'ru': 'Ибраев', 'en': 'Ibrayev', 'kk': 'Ибраев'},
        'bio': {
          'ru':
              'Арман Ибраев — проводник outdoor-практик, мастер церемониальных '
              'форматов и авторских телесных маршрутов. Соединяет движение, '
              'природу, дыхание и групповую динамику.',
          'en':
              'Arman Ibrayev is an outdoor practice guide, ceremonial format '
              'facilitator, and author of body-based routes. He combines '
              'movement, nature, breath, and group dynamics.',
          'kk':
              'Арман Ибраев — outdoor тәжірибелерінің жетекшісі, рәсімдік '
              'форматтар шебері және авторлық дене маршруттарының жүргізушісі. '
              'Ол қозғалысты, табиғатты, тынысты және топтық динамиканы '
              'біріктіреді.',
        },
        'avatarUrl':
            'https://res.cloudinary.com/dl04teduu/image/upload/PASTE_ARMAN_AVATAR_URL.jpg',
      });
  }

  static void _seedPrograms(WriteBatch batch) {
    const aigerimId = 'aigerim_amantaeva_001';
    const danaId = 'dana_sadykova_001';
    const armanId = 'arman_ibrayev_001';

    final programs = <Map<String, dynamic>>[
      {
        'uuid': 'hatha_yoga_aigerim_001',
        'category': 'yoga',
        'masterId': aigerimId,
        'price': 3500,
        'isActive': true,
        'isBookable': true,
        'imageUrl':
            'https://res.cloudinary.com/dl04teduu/image/upload/v1777762208/hatha_aigerim.jpg',
        'ritual': {
          'ru': 'Практика осознанного движения',
          'en': 'Mindful Movement Practice',
          'kk': 'Саналы қозғалыс тәжірибесі',
        },
        'title': {
          'ru': 'Хатха-йога с Айгерим',
          'en': 'Hatha Yoga with Aigerim',
          'kk': 'Айгеріммен Хатха-йога',
        },
        'text': {
          'ru':
              'Сбалансированная программа Хатха-йоги для развития гибкости, '
              'устойчивости, дыхания и внутренней концентрации. Подходит для '
              'тех, кто хочет мягко войти в практику и укрепить тело через '
              'осознанное движение.',
          'en':
              'A balanced Hatha Yoga program focused on flexibility, '
              'stability, breathing, and inner concentration. Suitable for '
              'those who want to enter the practice gently and strengthen '
              'the body through mindful movement.',
          'kk':
              'Икемділікті, тұрақтылықты, тыныс алуды және ішкі зейінді '
              'дамытуға бағытталған теңгерімді Хатха-йога бағдарламасы. '
              'Тәжірибеге жұмсақ кірісіп, саналы қозғалыс арқылы денені '
              'нығайтқысы келетіндерге қолайлы.',
        },
      },
      {
        'uuid': 'ashtanga_aigerim_001',
        'category': 'yoga',
        'masterId': aigerimId,
        'price': 4000,
        'isActive': true,
        'isBookable': true,
        'imageUrl':
            'https://res.cloudinary.com/dl04teduu/image/upload/q_auto/f_auto/v1778786639/ashtanga_aigerim.jpg',
        'ritual': {
          'ru': 'Динамичная практика силы и дыхания',
          'en': 'Dynamic Strength and Breath Practice',
          'kk': 'Күш пен тыныстың динамикалық тәжірибесі',
        },
        'title': {
          'ru': 'Аштанга-виньяса',
          'en': 'Ashtanga Vinyasa',
          'kk': 'Аштанга-виньяса',
        },
        'text': {
          'ru':
              'Энергичная практика с последовательной структурой асан, '
              'синхронизацией движения и дыхания. Подходит для тех, кто '
              'хочет развить выносливость, дисциплину и устойчивое внимание.',
          'en':
              'An energetic practice with a structured asana sequence and '
              'synchronization of movement and breath. Suitable for developing '
              'endurance, discipline, and steady attention.',
          'kk':
              'Асана реттілігі мен қозғалыс-тыныс үйлесіміне негізделген '
              'серпінді тәжірибе. Төзімділікті, тәртіпті және тұрақты зейінді '
              'дамытқысы келетіндерге арналған.',
        },
      },
      {
        'uuid': 'morning_meditation_dana_001',
        'category': 'meditation',
        'masterId': danaId,
        'price': 3000,
        'isActive': true,
        'isBookable': true,
        'imageUrl':
            'https://res.cloudinary.com/dl04teduu/image/upload/q_auto/f_auto/v1778786639/morning_meditation_dana.jpg',
        'ritual': {
          'ru': 'Мягкое утреннее возвращение к себе',
          'en': 'Soft Morning Return to Yourself',
          'kk': 'Таңғы жұмсақ өзіңе оралу тәжірибесі',
        },
        'title': {
          'ru': 'Утренняя медитация',
          'en': 'Morning Meditation',
          'kk': 'Таңғы медитация',
        },
        'text': {
          'ru':
              'Практика для спокойного начала дня: дыхание, наблюдение, '
              'мягкая настройка внимания и короткая телесная пауза. Подходит '
              'для начинающих и для тех, кто хочет снизить внутренний шум.',
          'en':
              'A practice for a calm start to the day: breathing, observation, '
              'gentle attention tuning, and a short body pause. Suitable for '
              'beginners and anyone who wants to reduce inner noise.',
          'kk':
              'Күнді сабырмен бастауға арналған тәжірибе: тыныс, бақылау, '
              'зейінді жұмсақ бағыттау және қысқа денелік үзіліс. Жаңадан '
              'бастаушыларға және ішкі шуды азайтқысы келетіндерге қолайлы.',
        },
      },
      {
        'uuid': 'breathwork_dana_001',
        'category': 'meditation',
        'masterId': danaId,
        'price': 3200,
        'isActive': true,
        'isBookable': true,
        'imageUrl':
            'https://res.cloudinary.com/dl04teduu/image/upload/q_auto/f_auto/v1778786639/breathwork_dana.jpg',
        'ritual': {
          'ru': 'Дыхание для восстановления нервной системы',
          'en': 'Breathwork for Nervous System Recovery',
          'kk': 'Жүйке жүйесін қалпына келтіруге арналған тыныс',
        },
        'title': {
          'ru': 'Дыхательная практика',
          'en': 'Breathwork Practice',
          'kk': 'Тыныс алу тәжірибесі',
        },
        'text': {
          'ru':
              'Занятие с простыми дыхательными техниками, которые помогают '
              'снизить напряжение, вернуть ощущение опоры и стабилизировать '
              'эмоциональное состояние.',
          'en':
              'A session with simple breathing techniques that help reduce '
              'tension, restore a sense of grounding, and stabilize the '
              'emotional state.',
          'kk':
              'Кернеуді азайтуға, ішкі тіректі сезінуге және эмоционалды '
              'жағдайды тұрақтандыруға көмектесетін қарапайым тыныс алу '
              'техникалары бар сабақ.',
        },
      },
      {
        'uuid': 'outdoor_movement_arman_001',
        'category': 'outdoor',
        'masterId': armanId,
        'price': 4500,
        'isActive': true,
        'isBookable': true,
        'imageUrl':
            'https://res.cloudinary.com/dl04teduu/image/upload/q_auto/f_auto/v1778786639/outdoor_movement_arman.jpg',
        'ritual': {
          'ru': 'Движение, дыхание и городская природа',
          'en': 'Movement, Breath, and Urban Nature',
          'kk': 'Қозғалыс, тыныс және қалалық табиғат',
        },
        'title': {
          'ru': 'Outdoor movement',
          'en': 'Outdoor Movement',
          'kk': 'Outdoor қозғалыс',
        },
        'text': {
          'ru':
              'Практика на свежем воздухе с мягкой разминкой, дыханием, '
              'осознанной ходьбой и телесными упражнениями. Подходит для '
              'перезагрузки после напряжённой недели.',
          'en':
              'An outdoor practice with gentle warm-up, breathing, mindful '
              'walking, and body exercises. Suitable for resetting after a '
              'busy week.',
          'kk':
              'Таза ауада өтетін жұмсақ қыздыру, тыныс, саналы жүру және '
              'дене жаттығулары бар тәжірибе. Қарбалас аптадан кейін '
              'қайта қалпына келуге қолайлы.',
        },
      },
      {
        'uuid': 'tea_ceremony_arman_001',
        'category': 'ceremony',
        'masterId': armanId,
        'price': 5000,
        'isActive': true,
        'isBookable': true,
        'imageUrl':
            'https://res.cloudinary.com/dl04teduu/image/upload/q_auto/f_auto/v1778786639/tea_ceremony_arman.jpg',
        'ritual': {
          'ru': 'Тихая церемония внимания',
          'en': 'Quiet Ceremony of Attention',
          'kk': 'Зейіннің тыныш рәсімі',
        },
        'title': {
          'ru': 'Чайная церемония',
          'en': 'Tea Ceremony',
          'kk': 'Шай рәсімі',
        },
        'text': {
          'ru':
              'Медитативный формат с чайной церемонией, тишиной, дыханием '
              'и мягким групповым присутствием. Создан для замедления, '
              'внутреннего равновесия и бережного контакта с собой.',
          'en':
              'A meditative format with a tea ceremony, silence, breathing, '
              'and soft group presence. Created for slowing down, inner '
              'balance, and gentle contact with yourself.',
          'kk':
              'Шай рәсімі, тыныштық, тыныс және жұмсақ топтық қатысу арқылы '
              'өтетін медитативті формат. Баяулау, ішкі тепе-теңдік және '
              'өзіңмен нәзік байланыс үшін жасалған.',
        },
      },
    ];

    for (final program in programs) {
      final programId = program['uuid'] as String;
      final ref = _firestore.collection('programs').doc(programId);

      batch.set(ref, program);
    }
  }

  static void _seedLessons(WriteBatch batch) {
    final lessons = <Map<String, dynamic>>[
      _lesson(
        uuid: 'hatha_yoga_aigerim_001_2026_05_18_0800',
        programId: 'hatha_yoga_aigerim_001',
        masterId: 'aigerim_amantaeva_001',
        start: DateTime(2026, 5, 30, 8),
        finish: DateTime(2026, 5, 30, 9),
      ),
      _lesson(
        uuid: 'hatha_yoga_aigerim_001_2026_05_20_0800',
        programId: 'hatha_yoga_aigerim_001',
        masterId: 'aigerim_amantaeva_001',
        start: DateTime(2026, 6, 1, 8),
        finish: DateTime(2026, 6, 1, 9),
      ),
      _lesson(
        uuid: 'hatha_yoga_aigerim_001_2026_05_23_1000',
        programId: 'hatha_yoga_aigerim_001',
        masterId: 'aigerim_amantaeva_001',
        start: DateTime(2026, 6, 2, 10),
        finish: DateTime(2026, 6, 2, 11),
      ),
      _lesson(
        uuid: 'ashtanga_aigerim_001_2026_05_19_1900',
        programId: 'ashtanga_aigerim_001',
        masterId: 'aigerim_amantaeva_001',
        start: DateTime(2026, 6, 19, 19),
        finish: DateTime(2026, 6, 19, 20, 15),
      ),
      _lesson(
        uuid: 'ashtanga_aigerim_001_2026_05_22_1900',
        programId: 'ashtanga_aigerim_001',
        masterId: 'aigerim_amantaeva_001',
        start: DateTime(2026, 6, 22, 19),
        finish: DateTime(2026, 6, 22, 20, 15),
      ),
      _lesson(
        uuid: 'morning_meditation_dana_001_2026_05_18_0730',
        programId: 'morning_meditation_dana_001',
        masterId: 'dana_sadykova_001',
        start: DateTime(2026, 6, 18, 7, 30),
        finish: DateTime(2026, 6, 18, 8, 15),
      ),
      _lesson(
        uuid: 'morning_meditation_dana_001_2026_05_21_0730',
        programId: 'morning_meditation_dana_001',
        masterId: 'dana_sadykova_001',
        start: DateTime(2026, 6, 21, 7, 30),
        finish: DateTime(2026, 6, 21, 8, 15),
      ),
      _lesson(
        uuid: 'morning_meditation_dana_001_2026_05_25_0730',
        programId: 'morning_meditation_dana_001',
        masterId: 'dana_sadykova_001',
        start: DateTime(2026, 6, 25, 7, 30),
        finish: DateTime(2026, 6, 25, 8, 15),
      ),
      _lesson(
        uuid: 'breathwork_dana_001_2026_05_20_1830',
        programId: 'breathwork_dana_001',
        masterId: 'dana_sadykova_001',
        start: DateTime(2026, 6, 20, 18, 30),
        finish: DateTime(2026, 6, 20, 19, 30),
      ),
      _lesson(
        uuid: 'breathwork_dana_001_2026_05_24_1200',
        programId: 'breathwork_dana_001',
        masterId: 'dana_sadykova_001',
        start: DateTime(2026, 6, 24, 12),
        finish: DateTime(2026, 6, 24, 13),
      ),
      _lesson(
        uuid: 'outdoor_movement_arman_001_2026_05_23_0900',
        programId: 'outdoor_movement_arman_001',
        masterId: 'arman_ibrayev_001',
        start: DateTime(2026, 6, 23, 9),
        finish: DateTime(2026, 6, 23, 10, 30),
      ),
      _lesson(
        uuid: 'outdoor_movement_arman_001_2026_05_30_0900',
        programId: 'outdoor_movement_arman_001',
        masterId: 'arman_ibrayev_001',
        start: DateTime(2026, 6, 30, 9),
        finish: DateTime(2026, 6, 30, 10, 30),
      ),
      _lesson(
        uuid: 'tea_ceremony_arman_001_2026_05_24_1700',
        programId: 'tea_ceremony_arman_001',
        masterId: 'arman_ibrayev_001',
        start: DateTime(2026, 6, 24, 17),
        finish: DateTime(2026, 6, 24, 18, 30),
      ),
      _lesson(
        uuid: 'tea_ceremony_arman_001_2026_05_31_1700',
        programId: 'tea_ceremony_arman_001',
        masterId: 'arman_ibrayev_001',
        start: DateTime(2026, 6, 31, 17),
        finish: DateTime(2026, 6, 31, 18, 30),
      ),
    ];

    for (final lesson in lessons) {
      final lessonId = lesson['uuid'] as String;
      final ref = _firestore.collection('lessons').doc(lessonId);

      batch.set(ref, lesson);
    }
  }

  static Map<String, dynamic> _lesson({
    required String uuid,
    required String programId,
    required String masterId,
    required DateTime start,
    required DateTime finish,
  }) {
    return <String, dynamic>{
      'uuid': uuid,
      'programId': programId,
      'masterId': masterId,
      'startDate': Timestamp.fromDate(start),
      'finishDate': Timestamp.fromDate(finish),
      'isBookable': true,
    };
  }

  // ── Classes seed (для Schedule tab + BookingBloc) ─────────────────────────
  // Коллекция 'classes' — отдельная от 'lessons'. Используется расписанием
  // и системой бронирования. Каждое занятие имеет maxParticipants=15.
  // set() с merge:false — не перезаписывает currentParticipants если документ
  // уже существует (для этого используется SetOptions(mergeFields)).

  static void _seedClasses(WriteBatch batch) {
    void addClass({
      required String id,
      required String title,
      required String type,
      required String trainerId,
      required DateTime datetime,
      required int durationMinutes,
      bool isIncludedInSubscription = true,
      double price = 0,
    }) {
      final ref = _firestore.collection('classes').doc(id);
      batch.set(
        ref,
        {
          'title': title,
          'type': type,
          'trainerId': trainerId,
          'datetime': Timestamp.fromDate(datetime),
          'durationMinutes': durationMinutes,
          'maxParticipants': 15,
          'currentParticipants': 0,
          'isIncludedInSubscription': isIncludedInSubscription,
          'price': price,
        },
        SetOptions(
          mergeFields: [
            'title',
            'type',
            'trainerId',
            'datetime',
            'durationMinutes',
            'maxParticipants',
            'isIncludedInSubscription',
            'price',
          ],
        ),
      );
    }

    // ── Июнь 2026 ────────────────────────────────────────────────────────────

    addClass(
      id: 'class_hatha_2026_06_04_0800',
      title: 'Хатха-йога с Айгерим',
      type: 'Йога',
      trainerId: 'aigerim_amantaeva_001',
      datetime: DateTime(2026, 6, 4, 8),
      durationMinutes: 60,
    );
    addClass(
      id: 'class_hatha_2026_06_06_0800',
      title: 'Хатха-йога с Айгерим',
      type: 'Йога',
      trainerId: 'aigerim_amantaeva_001',
      datetime: DateTime(2026, 6, 6, 8),
      durationMinutes: 60,
    );
    addClass(
      id: 'class_hatha_2026_06_09_0800',
      title: 'Хатха-йога с Айгерим',
      type: 'Йога',
      trainerId: 'aigerim_amantaeva_001',
      datetime: DateTime(2026, 6, 9, 8),
      durationMinutes: 60,
    );
    addClass(
      id: 'class_hatha_2026_06_11_0800',
      title: 'Хатха-йога с Айгерим',
      type: 'Йога',
      trainerId: 'aigerim_amantaeva_001',
      datetime: DateTime(2026, 6, 11, 8),
      durationMinutes: 60,
    );
    addClass(
      id: 'class_ashtanga_2026_06_05_1900',
      title: 'Аштанга-виньяса',
      type: 'Йога',
      trainerId: 'aigerim_amantaeva_001',
      datetime: DateTime(2026, 6, 5, 19),
      durationMinutes: 75,
    );
    addClass(
      id: 'class_ashtanga_2026_06_10_1900',
      title: 'Аштанга-виньяса',
      type: 'Йога',
      trainerId: 'aigerim_amantaeva_001',
      datetime: DateTime(2026, 6, 10, 19),
      durationMinutes: 75,
    );
    addClass(
      id: 'class_meditation_2026_06_04_0730',
      title: 'Утренняя медитация',
      type: 'Медитация',
      trainerId: 'dana_sadykova_001',
      datetime: DateTime(2026, 6, 4, 7, 30),
      durationMinutes: 45,
    );
    addClass(
      id: 'class_meditation_2026_06_07_0730',
      title: 'Утренняя медитация',
      type: 'Медитация',
      trainerId: 'dana_sadykova_001',
      datetime: DateTime(2026, 6, 7, 7, 30),
      durationMinutes: 45,
    );
    addClass(
      id: 'class_meditation_2026_06_11_0730',
      title: 'Утренняя медитация',
      type: 'Медитация',
      trainerId: 'dana_sadykova_001',
      datetime: DateTime(2026, 6, 11, 7, 30),
      durationMinutes: 45,
    );
    addClass(
      id: 'class_breathwork_2026_06_06_1830',
      title: 'Дыхательная практика',
      type: 'Медитация',
      trainerId: 'dana_sadykova_001',
      datetime: DateTime(2026, 6, 6, 18, 30),
      durationMinutes: 60,
    );
    addClass(
      id: 'class_breathwork_2026_06_10_1200',
      title: 'Дыхательная практика',
      type: 'Медитация',
      trainerId: 'dana_sadykova_001',
      datetime: DateTime(2026, 6, 10, 12),
      durationMinutes: 60,
    );
    addClass(
      id: 'class_outdoor_2026_06_07_0900',
      title: 'Outdoor movement',
      type: 'Аутдор',
      trainerId: 'arman_ibrayev_001',
      datetime: DateTime(2026, 6, 7, 9),
      durationMinutes: 90,
    );
    addClass(
      id: 'class_outdoor_2026_06_14_0900',
      title: 'Outdoor movement',
      type: 'Аутдор',
      trainerId: 'arman_ibrayev_001',
      datetime: DateTime(2026, 6, 14, 9),
      durationMinutes: 90,
    );
    addClass(
      id: 'class_tea_2026_06_08_1700',
      title: 'Чайная церемония',
      type: 'Церемония',
      trainerId: 'arman_ibrayev_001',
      datetime: DateTime(2026, 6, 8, 17),
      durationMinutes: 90,
      isIncludedInSubscription: false,
      price: 5000,
    );
    addClass(
      id: 'class_tea_2026_06_15_1700',
      title: 'Чайная церемония',
      type: 'Церемония',
      trainerId: 'arman_ibrayev_001',
      datetime: DateTime(2026, 6, 15, 17),
      durationMinutes: 90,
      isIncludedInSubscription: false,
      price: 5000,
    );
  }
}

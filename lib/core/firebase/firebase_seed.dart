import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;

  // ===== MASTERS =====

  final master1 = {
    'uuid': 'm1',
    'firstName': {
      'en': 'Anna',
      'ru': 'Анна',
      'kk': 'Анна',
    },
    'lastName': {
      'en': 'Smith',
      'ru': 'Смит',
      'kk': 'Смит',
    },
    'bio': {
      'en': 'Meditation teacher',
      'ru': 'Преподаватель медитации',
      'kk': 'Медитация мұғалімі',
    },
    'avatarUrl': 'https://example.com/anna.jpg',
  };

  final master2 = {
    'uuid': 'm2',
    'firstName': {
      'en': 'David',
      'ru': 'Дэвид',
      'kk': 'Дэвид',
    },
    'lastName': {
      'en': 'Lee',
      'ru': 'Ли',
      'kk': 'Ли',
    },
    'bio': {
      'en': 'Yoga instructor with 10 years experience',
      'ru': 'Инструктор по йоге с 10-летним опытом',
      'kk': '10 жылдық тәжірибесі бар йога нұсқаушысы',
    },
    'avatarUrl': 'https://example.com/david.jpg',
  };

  await db.collection('masters').doc('m1').set(master1);
  await db.collection('masters').doc('m2').set(master2);

  // ===== PROGRAMS (LessonModel) =====

  final programs = [
    {
      'uuid': 'p1',
      'ritual': {
        'en': 'Breathing and stretching',
        'ru': 'Дыхание и растяжка',
        'kk': 'Тыныс алу және созылу',
      },
      'title': {
        'en': 'Morning Flow Yoga',
        'ru': 'Утренняя йога флоу',
        'kk': 'Таңғы йога флоу',
      },
      'text': {
        'en': 'Start your morning with energy',
        'ru': 'Начни утро с энергии',
        'kk': 'Таңды энергиямен баста',
      },
      'startDate': DateTime(2026, 5, 1, 8, 0),
      'finishDate': DateTime(2026, 5, 1, 9, 0),
      'price': 10,
      'master': master2,
    },
    {
      'uuid': 'p2',
      'ritual': {
        'en': 'Relax and slow stretching',
        'ru': 'Расслабление и растяжка',
        'kk': 'Босаңсу және созылу',
      },
      'title': {
        'en': 'Evening Relax Yoga',
        'ru': 'Вечерняя расслабляющая йога',
        'kk': 'Кешкі босаңсыту йогасы',
      },
      'text': {
        'en': 'Release tension after a long day',
        'ru': 'Сними напряжение после дня',
        'kk': 'Күн соңында кернеуді босат',
      },
      'startDate': DateTime(2026, 5, 2, 18, 0),
      'finishDate': DateTime(2026, 5, 2, 19, 0),
      'price': 12,
      'master': master2,
    },
    {
      'uuid': 'p3',
      'ritual': {
        'en': 'Breathing and mindfulness',
        'ru': 'Дыхание и осознанность',
        'kk': 'Тыныс алу және зейін',
      },
      'title': {
        'en': 'Mindfulness Meditation',
        'ru': 'Медитация осознанности',
        'kk': 'Саналы медитация',
      },
      'text': {
        'en': 'Develop inner calm and awareness',
        'ru': 'Развивай внутренний покой',
        'kk': 'Ішкі тыныштықты дамыту',
      },
      'startDate': DateTime(2026, 5, 1, 7, 0),
      'finishDate': DateTime(2026, 5, 1, 8, 0),
      'price': 8,
      'master': master1,
    },
  ];

  for (final program in programs) {
    await db
        .collection('programs')
        .doc(program['uuid'] as String)
        .set(program, SetOptions(merge: true));
  }
}
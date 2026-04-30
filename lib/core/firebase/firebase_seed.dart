import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;

  await db.collection('app_content').doc('profile_about').set({
    'title': {'en': 'About us', 'ru': 'О нас', 'kk': 'Біз туралы'},
    'phoneDisplay': '+7 777 000 00 00',
    'phoneUri': 'tel:+77770000000',
    'email': 'hello@hygge.kz',
    'emailUri': 'mailto:hello@hygge.kz',
    'instagramConceptLabel': '@hy.gge_concept',
    'instagramConceptUrl': 'https://instagram.com/hy.gge_concept',
    'instagramBarLabel': '@hy.gge.specialty.bar',
    'instagramBarUrl': 'https://instagram.com/hy.gge.specialty.bar',
    'mapAddress': {
      'en': 'Almaty, Kazakhstan',
      'ru': 'Алматы, Казахстан',
      'kk': 'Алматы, Қазақстан',
    },
    'mapUrl': 'https://maps.google.com',
  }, SetOptions(merge: true));

  final master1 = {
    'uuid': 'm1',
    'firstName': {'en': 'Anna', 'ru': 'Анна', 'kk': 'Анна'},
    'lastName': {'en': 'Smith', 'ru': 'Смит', 'kk': 'Смит'},
    'bio': {
      'en': 'Meditation teacher',
      'ru': 'Преподаватель медитации',
      'kk': 'Медитация мұғалімі',
    },
    'avatarUrl': 'https://example.com/anna.jpg',
  };

  final master2 = {
    'uuid': 'm2',
    'firstName': {'en': 'David', 'ru': 'Дэвид', 'kk': 'Дэвид'},
    'lastName': {'en': 'Lee', 'ru': 'Ли', 'kk': 'Ли'},
    'bio': {
      'en': 'Yoga instructor with 10 years experience',
      'ru': 'Инструктор по йоге с 10-летним опытом',
      'kk': '10 жылдық тәжірибесі бар йога нұсқаушысы',
    },
    'avatarUrl': 'https://example.com/david.jpg',
  };

  await db
      .collection('masters')
      .doc('m1')
      .set(master1, SetOptions(merge: true));

  await db
      .collection('masters')
      .doc('m2')
      .set(master2, SetOptions(merge: true));

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
      'price': 5000,
      'master': master2,
      'isActive': true,
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
      'price': 6000,
      'master': master2,
      'isActive': true,
    },
    {
      'uuid': 'p3',
      'ritual': {
        'en': 'Mind and breath focus',
        'ru': 'Фокус на дыхании и сознании',
        'kk': 'Тыныс пен санаға назар',
      },
      'title': {
        'en': 'Mindfulness Meditation',
        'ru': 'Медитация осознанности',
        'kk': 'Саналы медитация',
      },
      'text': {
        'en': 'Deep calm and awareness training',
        'ru': 'Глубокое спокойствие и осознанность',
        'kk': 'Терең тыныштық пен зейін',
      },
      'price': 4000,
      'master': master1,
      'isActive': true,
    },
    {
      'uuid': 'p4',
      'ritual': {
        'en': 'Balance and core',
        'ru': 'Баланс и корпус',
        'kk': 'Тепе-теңдік пен корпус',
      },
      'title': {'en': 'Power Yoga', 'ru': 'Силовая йога', 'kk': 'Күштік йога'},
      'text': {
        'en': 'Build strength and endurance',
        'ru': 'Развитие силы и выносливости',
        'kk': 'Күш пен төзімділік',
      },
      'price': 7000,
      'master': master2,
      'isActive': true,
    },
  ];

  for (final program in programs) {
    await db
        .collection('programs')
        .doc(program['uuid'] as String)
        .set(program, SetOptions(merge: true));
  }

  final now = DateTime.now();

  Timestamp ts(DateTime value) => Timestamp.fromDate(value);

  final lessons = [
    {
      'uuid': 'l1',
      'programId': 'p1',
      'startDate': ts(now.add(const Duration(days: 1, hours: 8))),
      'finishDate': ts(now.add(const Duration(days: 1, hours: 9))),
      'price': 5000,
      'master': master2,
      'isAvailable': true,
    },
    {
      'uuid': 'l2',
      'programId': 'p1',
      'startDate': ts(now.add(const Duration(days: 3, hours: 8))),
      'finishDate': ts(now.add(const Duration(days: 3, hours: 9))),
      'price': 5000,
      'master': master2,
      'isAvailable': true,
    },
    {
      'uuid': 'l3',
      'programId': 'p2',
      'startDate': ts(now.add(const Duration(days: 1, hours: 18))),
      'finishDate': ts(now.add(const Duration(days: 1, hours: 19))),
      'price': 6000,
      'master': master2,
      'isAvailable': true,
    },
    {
      'uuid': 'l4',
      'programId': 'p3',
      'startDate': ts(now.add(const Duration(hours: 6))),
      'finishDate': ts(now.add(const Duration(hours: 7))),
      'price': 4000,
      'master': master1,
      'isAvailable': true,
    },
    {
      'uuid': 'l5',
      'programId': 'p3',
      'startDate': ts(now.add(const Duration(days: 2, hours: 6))),
      'finishDate': ts(now.add(const Duration(days: 2, hours: 7))),
      'price': 4000,
      'master': master1,
      'isAvailable': true,
    },
    {
      'uuid': 'l6',
      'programId': 'p4',
      'startDate': ts(now.add(const Duration(days: 1, hours: 10))),
      'finishDate': ts(now.add(const Duration(days: 1, hours: 11))),
      'price': 7000,
      'master': master2,
      'isAvailable': true,
    },
    {
      'uuid': 'l7',
      'programId': 'p4',
      'startDate': ts(now.add(const Duration(days: 4, hours: 10))),
      'finishDate': ts(now.add(const Duration(days: 4, hours: 11))),
      'price': 7000,
      'master': master2,
      'isAvailable': true,
    },
  ];

  for (final lesson in lessons) {
    await db
        .collection('lessons')
        .doc(lesson['uuid'] as String)
        .set(lesson, SetOptions(merge: true));
  }

  final upcomingPrograms = [
    {
      'uuid': 'up1',
      'ritual': {
        'en': 'Mountain yoga retreat',
        'ru': 'Йога-ретрит в горах',
        'kk': 'Таудағы йога ретриті',
      },
      'title': {
        'en': 'Summer Yoga in the Mountains',
        'ru': 'Летняя йога в горах',
        'kk': 'Жазғы таудағы йога',
      },
      'text': {
        'en':
            'A future outdoor yoga program planned for summer. Booking will open later.',
        'ru':
            'Будущая выездная программа по йоге на лето. Запись откроется позже.',
        'kk':
            'Жазға жоспарланған ашық ауадағы йога бағдарламасы. Жазылу кейін ашылады.',
      },
      'availableFrom': ts(DateTime(now.year, now.month + 2, 1, 9)),
      'startDate': ts(DateTime(now.year, now.month + 2, 1, 9)),
      'finishDate': ts(DateTime(now.year, now.month + 2, 1, 10)),
      'price': 25000,
      'master': master2,
      'isVisible': true,
      'isBookable': false,
    },
    {
      'uuid': 'up2',
      'ritual': {
        'en': 'Silent meditation retreat',
        'ru': 'Ретрит тишины',
        'kk': 'Тыныштық ретриті',
      },
      'title': {
        'en': 'Autumn Silence Retreat',
        'ru': 'Осенний ретрит тишины',
        'kk': 'Күзгі тыныштық ретриті',
      },
      'text': {
        'en':
            'A future meditation retreat focused on silence, breath and awareness.',
        'ru': 'Будущий медитационный ретрит о тишине, дыхании и осознанности.',
        'kk':
            'Тыныштық, тыныс және зейінге арналған болашақ медитациялық ретрит.',
      },
      'availableFrom': ts(DateTime(now.year, now.month + 3, 10, 8)),
      'startDate': ts(DateTime(now.year, now.month + 3, 10, 8)),
      'finishDate': ts(DateTime(now.year, now.month + 3, 10, 9)),
      'price': 30000,
      'master': master1,
      'isVisible': true,
      'isBookable': false,
    },
  ];

  for (final program in upcomingPrograms) {
    await db
        .collection('upcoming_programs')
        .doc(program['uuid'] as String)
        .set(program, SetOptions(merge: true));
  }
}

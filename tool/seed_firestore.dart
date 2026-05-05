// Seeding tool uses print for user-facing progress output.
// ignore_for_file: avoid_print
import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run tool/seed_firestore.dart <userId>');
    print('');
    print(
      '  userId — your Firebase Auth UID '
      '(find it in Firebase Console → Authentication → Users)',
    );
    exit(1);
  }

  final userId = args[0];
  final projectRoot = Directory.current.path;
  final serviceAccountPath = '$projectRoot/service_account.json';
  final functionsDir = '$projectRoot/functions';
  final adminModulePath = '$functionsDir/node_modules/firebase-admin';
  final tmpScriptPath = '$functionsDir/.seed_tmp.js';

  // Verify service_account.json exists
  if (!File(serviceAccountPath).existsSync()) {
    print('ERROR: service_account.json not found at $serviceAccountPath');
    print('');
    print('Download it from:');
    print(
      '  Firebase Console → Project Settings → '
      'Service accounts → Generate new private key',
    );
    print('  Save as: service_account.json in project root');
    exit(1);
  }

  // Verify firebase-admin is installed
  if (!Directory(adminModulePath).existsSync()) {
    print('ERROR: firebase-admin not found at $adminModulePath');
    print('');
    print('Run: cd functions && npm install');
    exit(1);
  }

  print('Seeding Firestore for userId: $userId');
  print('');

  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));
  final inThreeDays = now.add(const Duration(days: 3));
  final inFourteenDays = now.add(const Duration(days: 14));

  final yogaDatetime = DateTime(
      tomorrow.year, tomorrow.month, tomorrow.day, 8);
  final meditationDatetime = DateTime(
      inThreeDays.year, inThreeDays.month, inThreeDays.day, 19);
  final retreatDatetime = DateTime(
      inFourteenDays.year, inFourteenDays.month, inFourteenDays.day, 7);

  final subscriptionStart = DateTime(now.year, now.month);
  final subscriptionEnd = subscriptionStart.add(const Duration(days: 30));

  final jsCode = '''
const admin = require('firebase-admin');
const serviceAccount = require('../service_account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function seed() {
  const userId = '${_escapeJs(userId)}';

  // Classes
  const classes = [
    {
      id: 'class_yoga_001',
      data: {
        title: 'Утренняя йога',
        type: 'Йога',
        datetime: admin.firestore.Timestamp.fromDate(new Date('${yogaDatetime.toIso8601String()}')),
        durationMinutes: 90,
        trainerId: 'trainer_anna',
        maxParticipants: 10,
        currentParticipants: 3,
        price: 0,
        isIncludedInSubscription: true,
      },
    },
    {
      id: 'class_meditation_001',
      data: {
        title: 'Вечерняя медитация',
        type: 'Медитация',
        datetime: admin.firestore.Timestamp.fromDate(new Date('${meditationDatetime.toIso8601String()}')),
        durationMinutes: 60,
        trainerId: 'trainer_elena',
        maxParticipants: 8,
        currentParticipants: 1,
        price: 0,
        isIncludedInSubscription: true,
      },
    },
    {
      id: 'class_tour_001',
      data: {
        title: 'Горный ретрит',
        type: 'Выездная практика',
        datetime: admin.firestore.Timestamp.fromDate(new Date('${retreatDatetime.toIso8601String()}')),
        durationMinutes: 480,
        trainerId: 'trainer_anna',
        maxParticipants: 12,
        currentParticipants: 5,
        price: 25000,
        isIncludedInSubscription: false,
      },
    },
  ];

  for (const cls of classes) {
    await db.collection('classes').doc(cls.id).set(cls.data);
    console.log('  ✓ class ' + cls.id + ' — ' + cls.data.title);
  }

  // Subscription
  await db.collection('subscriptions').doc(userId).set({
    id: userId,
    userId: userId,
    totalSessions: 10,
    usedSessions: 3,
    startDate: admin.firestore.Timestamp.fromDate(new Date('${subscriptionStart.toIso8601String()}')),
    endDate: admin.firestore.Timestamp.fromDate(new Date('${subscriptionEnd.toIso8601String()}')),
    isActive: true,
  });
  console.log('  ✓ subscription for userId: ' + userId);

  console.log('');
  console.log('Done! Open the app and check:');
  console.log('  Schedule tab  — 3 class cards');
  console.log('  Profile → My Subscription — 7 of 10 sessions remaining');
}

seed().then(() => process.exit(0)).catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});
''';

  final tmpFile = File(tmpScriptPath);
  try {
    tmpFile.writeAsStringSync(jsCode);

    final result = await Process.run(
      'node',
      ['.seed_tmp.js'],
      workingDirectory: functionsDir,
    );

    if (result.stdout.toString().isNotEmpty) {
      print(result.stdout);
    }
    if (result.stderr.toString().isNotEmpty) {
      stderr.write(result.stderr);
    }

    if (result.exitCode != 0) {
      print('ERROR: seed script exited with code ${result.exitCode}');
      exit(result.exitCode);
    }
  } finally {
    if (tmpFile.existsSync()) tmpFile.deleteSync();
  }
}

String _escapeJs(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

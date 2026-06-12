// scripts/create_test_class.js
//
// Создаёт тестовое занятие + бронь в Firestore для проверки push-уведомлений.
// sendClassReminders (каждые 15 мин) найдёт эту бронь и отправит FCM.
//
// Использование:
//   node scripts/create_test_class.js <USER_ID>
//
// Авторизация (по убыванию приоритета):
//   1. service_account.json в корне проекта
//   2. functions/service_account.json
//   3. Application Default Credentials (gcloud auth application-default login)
//
// firebase-admin берётся из functions/node_modules — отдельный npm install не нужен.

'use strict';

const path = require('path');

// ── firebase-admin из functions/node_modules ─────────────────────────────────
const admin = require(
  path.join(__dirname, '..', 'functions', 'node_modules', 'firebase-admin'),
);

// ── Авторизация ───────────────────────────────────────────────────────────────
const KEY_CANDIDATES = [
  path.join(__dirname, '..', 'service_account.json'),
  path.join(__dirname, '..', 'functions', 'service_account.json'),
  path.join(__dirname, 'service_account.json'),
];

let credentialSource = 'Application Default Credentials';
let appOptions = {};

for (const keyPath of KEY_CANDIDATES) {
  try {
    const sa = require(keyPath);
    appOptions = { credential: admin.credential.cert(sa) };
    credentialSource = keyPath;
    break;
  } catch {
    // ключ не найден — пробуем следующий
  }
}

admin.initializeApp(appOptions);

const db = admin.firestore();

// ── Главная функция ───────────────────────────────────────────────────────────
async function main() {
  const userId = process.argv[2];

  if (!userId) {
    console.error('');
    console.error('Использование: node scripts/create_test_class.js <USER_ID>');
    console.error('');
    process.exit(1);
  }

  console.log(`\nАвторизация: ${credentialSource}`);
  console.log(`userId: ${userId}\n`);

  // Время занятия: сейчас + 2ч 15мин
  const now = new Date();
  const classTime = new Date(now.getTime() + (2 * 60 + 15) * 60 * 1000);

  // ── Занятие ───────────────────────────────────────────────────────────────
  const classRef = db.collection('classes').doc();
  const classId = classRef.id;

  await classRef.set({
    id: classId,
    title: 'Тест-занятие (авто)',
    type: 'Тестовый класс',
    datetime: admin.firestore.Timestamp.fromDate(classTime),
    durationMinutes: 60,
    trainerId: 'test-trainer',
    maxParticipants: 10,
    currentParticipants: 0,
    price: 0,
    isIncludedInSubscription: true,
    programId: '',
  });

  // ── Бронь ─────────────────────────────────────────────────────────────────
  const bookingRef = db
    .collection('bookings')
    .doc(userId)
    .collection('userBookings')
    .doc();
  const bookingId = bookingRef.id;

  await bookingRef.set({
    id: bookingId,
    userId,
    classId,
    datetime: admin.firestore.Timestamp.fromDate(classTime),
    status: 'pending',
    notificationSent: false,
  });

  // ── Вывод ─────────────────────────────────────────────────────────────────
  const localTime = classTime.toLocaleString('ru-RU', {
    timeZone: 'Asia/Almaty',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });

  // Планировщик запускается каждые 15 мин (:00 :15 :30 :45 в Алматы).
  // Считаем минуты до следующего запуска по текущему времени Алматы (UTC+5).
  const almatyMinutes = (now.getUTCMinutes() + 5 * 60) % 60;
  const cycle = almatyMinutes % 15;
  const minutesUntilNext = cycle === 0 ? 15 : 15 - cycle;

  console.log('✅  Тестовые данные созданы!\n');
  console.log(`    ID занятия:   ${classId}`);
  console.log(`    Время:        ${localTime} (Алматы / UTC+5)`);
  console.log(`    ID брони:     ${bookingId}`);
  console.log('');
  console.log(`    Планировщик запустится примерно через ${minutesUntilNext} мин.`);
  console.log(`    ➜  Уведомление ожидается через ~${minutesUntilNext} мин.\n`);
  console.log('    Удалить вручную:');
  console.log(`      classes/${classId}`);
  console.log(`      bookings/${userId}/userBookings/${bookingId}\n`);
}

main().catch((err) => {
  console.error('\nОшибка:', err.message ?? err);
  process.exit(1);
});

# Тестовые данные Firestore

## Шаг 0 — узнай свой userId

1. Запусти приложение на Android-устройстве
2. Войди через Google
3. Открой **Firebase Console → Authentication → Users**
4. Скопируй **User UID** (например: `abc123XYZ`)

Во всех командах ниже замени `YOUR_USER_ID` на этот UID.

---

## Вставка через Firebase Console

Открой: **Firebase Console → Firestore Database → + Start collection / + Add document**

---

## Коллекция `classes` — тестовые занятия

### Документ 1 — Йога (входит в абонемент)

**Collection:** `classes`  
**Document ID:** `class_yoga_001` *(или авто-генерация)*

```json
{
  "title": "Утренняя йога",
  "type": "Йога",
  "datetime": "2025-06-10T08:00:00+06:00",
  "durationMinutes": 90,
  "trainerId": "trainer_anna",
  "maxParticipants": 10,
  "currentParticipants": 3,
  "price": 0,
  "isIncludedInSubscription": true
}
```

> В Firebase Console поле `datetime` создавай как **Timestamp**:  
> нажми «Add field» → тип **timestamp** → выбери дату/время.

### Документ 2 — Медитация (входит в абонемент)

**Document ID:** `class_meditation_001`

```json
{
  "title": "Вечерняя медитация",
  "type": "Медитация",
  "datetime": "2025-06-11T19:00:00+06:00",
  "durationMinutes": 60,
  "trainerId": "trainer_elena",
  "maxParticipants": 8,
  "currentParticipants": 1,
  "price": 0,
  "isIncludedInSubscription": true
}
```

### Документ 3 — Выездной тур (НЕ входит в абонемент)

**Document ID:** `class_tour_001`

```json
{
  "title": "Горный ретрит",
  "type": "Выездная практика",
  "datetime": "2025-06-20T07:00:00+06:00",
  "durationMinutes": 480,
  "trainerId": "trainer_anna",
  "maxParticipants": 12,
  "currentParticipants": 5,
  "price": 25000,
  "isIncludedInSubscription": false
}
```

---

## Коллекция `subscriptions` — тестовый абонемент

**Collection:** `subscriptions`  
**Document ID:** `YOUR_USER_ID` *(точно твой UID)*

```json
{
  "id": "YOUR_USER_ID",
  "userId": "YOUR_USER_ID",
  "totalSessions": 10,
  "usedSessions": 3,
  "startDate": "2025-05-01T00:00:00+06:00",
  "endDate": "2025-07-31T23:59:59+06:00",
  "isActive": true
}
```

> Поля `startDate` и `endDate` создавай как **Timestamp**.  
> Убедись, что `endDate` в будущем и `isActive: true`.

---

## Проверка в приложении

| Экран | Что ожидать |
|-------|-------------|
| **Расписание** | 3 карточки занятий. На календаре — точки на 10, 11, 20 июня |
| **Карточка «Утренняя йога»** | Кнопка «Записаться» активна |
| **Карточка «Горный ретрит»** | Сообщение «Запись через администратора» |
| **Профиль → Мой абонемент** | Показывает 7 из 10 занятий, прогресс-бар, дата окончания |

---

## Быстрый способ через Firebase CLI (опционально)

Если установлен `firebase-admin` локально, можно запустить seed-скрипт:

```bash
cd firestore_seed && node seed.js YOUR_USER_ID
```

*(Скрипт `firestore_seed/seed.js` — создай при необходимости)*

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onBookingStatusChanged = exports.processAutoConfirm = exports.sendClassReminders = void 0;
const admin = require("firebase-admin");
const functions = require("firebase-functions/v2");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firestore_1 = require("firebase-functions/v2/firestore");
admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();
// ── Константа: за сколько часов до занятия отправлять уведомление ────────────
const NOTIFICATION_HOURS_BEFORE = 2;
// ── Константа: через сколько часов после уведомления считать подтверждением ──
const AUTO_CONFIRM_HOURS = 1;
// ─────────────────────────────────────────────────────────────────────────────
// Scheduled function: каждые 15 минут проверяет брони и отправляет уведомления
// ─────────────────────────────────────────────────────────────────────────────
exports.sendClassReminders = (0, scheduler_1.onSchedule)({ schedule: "every 15 minutes", timeZone: "Asia/Almaty" }, async () => {
    var _a, _b;
    const now = admin.firestore.Timestamp.now();
    const windowStart = admin.firestore.Timestamp.fromMillis(now.toMillis() + NOTIFICATION_HOURS_BEFORE * 60 * 60 * 1000 - 15 * 60 * 1000);
    const windowEnd = admin.firestore.Timestamp.fromMillis(now.toMillis() + NOTIFICATION_HOURS_BEFORE * 60 * 60 * 1000);
    // Получаем все занятия в ближайшем окне
    const classesSnap = await db
        .collection("classes")
        .where("datetime", ">=", windowStart)
        .where("datetime", "<=", windowEnd)
        .get();
    if (classesSnap.empty) {
        functions.logger.info("No upcoming classes in notification window");
        return;
    }
    for (const classDoc of classesSnap.docs) {
        const classData = classDoc.data();
        const classId = classDoc.id;
        const classTitle = (_a = classData.title) !== null && _a !== void 0 ? _a : "Занятие";
        const classTime = classData.datetime;
        // Ищем все pending-брони на это занятие, которым ещё не отправлено уведомление
        const bookingsQuery = await db
            .collectionGroup("userBookings")
            .where("classId", "==", classId)
            .where("status", "==", "pending")
            .where("notificationSent", "==", false)
            .get();
        for (const bookingDoc of bookingsQuery.docs) {
            // Путь: bookings/{userId}/userBookings/{bookingId}
            const pathParts = bookingDoc.ref.path.split("/");
            const userId = pathParts[1];
            const bookingId = bookingDoc.id;
            // Получаем FCM токен пользователя
            const userSnap = await db.collection("users").doc(userId).get();
            const fcmToken = (_b = userSnap.data()) === null || _b === void 0 ? void 0 : _b.fcmToken;
            if (!fcmToken) {
                functions.logger.warn(`No FCM token for user ${userId}`);
                continue;
            }
            const timeStr = _formatTime(classTime.toDate());
            // Отправляем FCM уведомление с action buttons
            await messaging.send({
                token: fcmToken,
                notification: {
                    title: "Напоминание о занятии",
                    body: `Вы придёте на «${classTitle}» сегодня в ${timeStr}?`,
                },
                data: {
                    type: "classReminder",
                    classId,
                    bookingId,
                    userId,
                    classTitle,
                    action: "confirm_prompt",
                },
                android: {
                    notification: {
                        channelId: "class_reminders",
                        priority: "high",
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            // iOS: категория CLASS_REMINDER зарегистрирована в AppDelegate
                            // и содержит action buttons «Да» / «Нет»
                            category: "CLASS_REMINDER",
                            sound: "default",
                        },
                    },
                },
            });
            // Помечаем уведомление как отправленное
            await bookingDoc.ref.update({ notificationSent: true });
            // Планируем авто-подтверждение через AUTO_CONFIRM_HOURS
            await db.collection("_autoConfirmQueue").add({
                userId,
                bookingId,
                classId,
                confirmAt: admin.firestore.Timestamp.fromMillis(now.toMillis() + AUTO_CONFIRM_HOURS * 60 * 60 * 1000),
                processed: false,
            });
            functions.logger.info(`Notification sent to ${userId} for booking ${bookingId}`);
        }
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Scheduled function: обрабатывает авто-подтверждения (нет ответа = "Да")
// ─────────────────────────────────────────────────────────────────────────────
exports.processAutoConfirm = (0, scheduler_1.onSchedule)({ schedule: "every 15 minutes", timeZone: "Asia/Almaty" }, async () => {
    var _a, _b;
    const now = admin.firestore.Timestamp.now();
    const queueSnap = await db
        .collection("_autoConfirmQueue")
        .where("processed", "==", false)
        .where("confirmAt", "<=", now)
        .get();
    for (const queueDoc of queueSnap.docs) {
        const { userId, bookingId } = queueDoc.data();
        const bookingRef = db
            .collection("bookings")
            .doc(userId)
            .collection("userBookings")
            .doc(bookingId);
        const bookingSnap = await bookingRef.get();
        if (!bookingSnap.exists) {
            await queueDoc.ref.update({ processed: true });
            continue;
        }
        const status = (_b = (_a = bookingSnap.data()) === null || _a === void 0 ? void 0 : _a.status) !== null && _b !== void 0 ? _b : "pending";
        // Только если всё ещё pending (не ответил) — авто-подтверждаем
        if (status === "pending") {
            await _confirmBookingAndDeduct(userId, bookingId, bookingRef);
            functions.logger.info(`Auto-confirmed booking ${bookingId} for user ${userId}`);
        }
        await queueDoc.ref.update({ processed: true });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Firestore trigger: пользователь ответил на уведомление
// Клиент обновляет bookings/{userId}/userBookings/{bookingId}.status
// ─────────────────────────────────────────────────────────────────────────────
exports.onBookingStatusChanged = (0, firestore_1.onDocumentUpdated)("bookings/{userId}/userBookings/{bookingId}", async (event) => {
    var _a, _b, _c, _d;
    const before = (_b = (_a = event.data) === null || _a === void 0 ? void 0 : _a.before) === null || _b === void 0 ? void 0 : _b.data();
    const after = (_d = (_c = event.data) === null || _c === void 0 ? void 0 : _c.after) === null || _d === void 0 ? void 0 : _d.data();
    if (!before || !after)
        return;
    if (before.status === after.status)
        return;
    const userId = event.params.userId;
    const bookingId = event.params.bookingId;
    const newStatus = after.status;
    if (newStatus === "confirmed") {
        const bookingRef = db
            .collection("bookings")
            .doc(userId)
            .collection("userBookings")
            .doc(bookingId);
        await _confirmBookingAndDeduct(userId, bookingId, bookingRef);
    }
    else if (newStatus === "cancelled") {
        // Пользователь ответил "Нет" — уменьшаем счётчик участников
        const classId = after.classId;
        if (classId) {
            await _decrementParticipants(classId);
        }
        functions.logger.info(`Booking ${bookingId} cancelled by user ${userId}`);
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
async function _confirmBookingAndDeduct(userId, bookingId, bookingRef) {
    await db.runTransaction(async (tx) => {
        var _a, _b, _c, _d, _e;
        const bookingSnap = await tx.get(bookingRef);
        if (!bookingSnap.exists)
            return;
        // Статус уже не pending — пропускаем (идемпотентность)
        if (((_a = bookingSnap.data()) === null || _a === void 0 ? void 0 : _a.status) !== "pending")
            return;
        const subRef = db.collection("subscriptions").doc(userId);
        const subSnap = await tx.get(subRef);
        if (!subSnap.exists) {
            functions.logger.warn(`No subscription for user ${userId}, confirming without deduct`);
            tx.update(bookingRef, { status: "confirmed" });
            return;
        }
        const used = (_c = (_b = subSnap.data()) === null || _b === void 0 ? void 0 : _b.usedSessions) !== null && _c !== void 0 ? _c : 0;
        const total = (_e = (_d = subSnap.data()) === null || _d === void 0 ? void 0 : _d.totalSessions) !== null && _e !== void 0 ? _e : 0;
        if (used >= total) {
            functions.logger.warn(`Subscription exhausted for user ${userId}`);
            tx.update(bookingRef, { status: "confirmed" });
            return;
        }
        tx.update(bookingRef, { status: "confirmed" });
        tx.update(subRef, { usedSessions: used + 1 });
    });
}
async function _decrementParticipants(classId) {
    const classRef = db.collection("classes").doc(classId);
    await db.runTransaction(async (tx) => {
        var _a, _b;
        const snap = await tx.get(classRef);
        if (!snap.exists)
            return;
        const current = (_b = (_a = snap.data()) === null || _a === void 0 ? void 0 : _a.currentParticipants) !== null && _b !== void 0 ? _b : 0;
        tx.update(classRef, {
            currentParticipants: current > 0 ? current - 1 : 0,
        });
    });
}
function _formatTime(date) {
    const h = date.getHours().toString().padStart(2, "0");
    const m = date.getMinutes().toString().padStart(2, "0");
    return `${h}:${m}`;
}
//# sourceMappingURL=index.js.map
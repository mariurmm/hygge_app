"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onBookingStatusChanged = exports.processAutoConfirm = exports.sendClassReminders = void 0;
const admin = require("firebase-admin");
const logger_1 = require("firebase-functions/logger");
const scheduler_1 = require("firebase-functions/scheduler");
const firestore_1 = require("firebase-functions/firestore");
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
        logger_1.logger.info("No upcoming classes in notification window");
        return;
    }
    for (const classDoc of classesSnap.docs) {
        const classData = classDoc.data();
        const classId = classDoc.id;
        const classTitle = classData.title ?? "Занятие";
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
            const fcmToken = userSnap.data()?.fcmToken;
            if (!fcmToken) {
                logger_1.logger.warn(`No FCM token for user ${userId}`);
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
            logger_1.logger.info(`Notification sent to ${userId} for booking ${bookingId}`);
        }
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Scheduled function: обрабатывает авто-подтверждения (нет ответа = "Да")
// ─────────────────────────────────────────────────────────────────────────────
exports.processAutoConfirm = (0, scheduler_1.onSchedule)({ schedule: "every 15 minutes", timeZone: "Asia/Almaty" }, async () => {
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
        const status = bookingSnap.data()?.status ?? "pending";
        // Только если всё ещё pending (не ответил) — авто-подтверждаем
        if (status === "pending") {
            await _confirmBookingAndDeduct(userId, bookingId, bookingRef);
            logger_1.logger.info(`Auto-confirmed booking ${bookingId} for user ${userId}`);
        }
        await queueDoc.ref.update({ processed: true });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Firestore trigger: пользователь ответил на уведомление
// Клиент обновляет bookings/{userId}/userBookings/{bookingId}.status
// ─────────────────────────────────────────────────────────────────────────────
exports.onBookingStatusChanged = (0, firestore_1.onDocumentUpdated)("bookings/{userId}/userBookings/{bookingId}", async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
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
        // Уменьшаем счётчик участников
        const classId = after.classId;
        if (classId) {
            await _decrementParticipants(classId);
        }
        // Если бронь была подтверждена — возвращаем занятие в абонемент
        const prevStatus = before.status;
        if (prevStatus === "confirmed") {
            await _restoreSession(userId);
        }
        logger_1.logger.info(`Booking ${bookingId} cancelled by user ${userId} (was ${prevStatus})`);
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
async function _confirmBookingAndDeduct(userId, bookingId, bookingRef) {
    await db.runTransaction(async (tx) => {
        const bookingSnap = await tx.get(bookingRef);
        if (!bookingSnap.exists)
            return;
        // Статус уже не pending — пропускаем (идемпотентность)
        if (bookingSnap.data()?.status !== "pending")
            return;
        const subRef = db.collection("subscriptions").doc(userId);
        const subSnap = await tx.get(subRef);
        if (!subSnap.exists) {
            logger_1.logger.warn(`No subscription for user ${userId}, confirming without deduct`);
            tx.update(bookingRef, { status: "confirmed" });
            return;
        }
        const used = subSnap.data()?.usedSessions ?? 0;
        const total = subSnap.data()?.totalSessions ?? 0;
        if (used >= total) {
            logger_1.logger.warn(`Subscription exhausted for user ${userId}`);
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
        const snap = await tx.get(classRef);
        if (!snap.exists)
            return;
        const current = snap.data()?.currentParticipants ?? 0;
        tx.update(classRef, {
            currentParticipants: current > 0 ? current - 1 : 0,
        });
    });
}
async function _restoreSession(userId) {
    const subRef = db.collection("subscriptions").doc(userId);
    await db.runTransaction(async (tx) => {
        const snap = await tx.get(subRef);
        if (!snap.exists)
            return;
        const used = snap.data()?.usedSessions ?? 0;
        tx.update(subRef, { usedSessions: used > 0 ? used - 1 : 0 });
    });
}
function _formatTime(date) {
    const h = date.getHours().toString().padStart(2, "0");
    const m = date.getMinutes().toString().padStart(2, "0");
    return `${h}:${m}`;
}
//# sourceMappingURL=index.js.map
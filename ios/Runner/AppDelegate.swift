import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    // ── FCM delegate ──────────────────────────────────────────────
    Messaging.messaging().delegate = self

    // ── Запрашиваем разрешение на уведомления ─────────────────────
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge, .sound]
    ) { _, _ in }
    application.registerForRemoteNotifications()

    // ── Регистрируем категорию CLASS_REMINDER с action buttons ─────
    _registerNotificationCategories()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ── Получили APNs токен — передаём в FCM ──────────────────────────
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }

  // ── Уведомление пришло пока приложение открыто ────────────────────
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.alert, .badge, .sound])
  }

  // ── Пользователь нажал на action button ───────────────────────────
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    let bookingId = userInfo["bookingId"] as? String ?? ""
    let userId    = userInfo["userId"]    as? String ?? ""

    switch response.actionIdentifier {
    case "ACTION_CONFIRM":
      _updateBookingStatus(userId: userId, bookingId: bookingId, status: "confirmed")
    case "ACTION_CANCEL":
      _updateBookingStatus(userId: userId, bookingId: bookingId, status: "cancelled")
    default:
      break
    }

    completionHandler()
  }

  // ── Private helpers ───────────────────────────────────────────────

  private func _registerNotificationCategories() {
    let confirmAction = UNNotificationAction(
      identifier: "ACTION_CONFIRM",
      title: "Да",
      options: []
    )
    let cancelAction = UNNotificationAction(
      identifier: "ACTION_CANCEL",
      title: "Нет",
      options: [.destructive]
    )
    let reminderCategory = UNNotificationCategory(
      identifier: "CLASS_REMINDER",
      actions: [confirmAction, cancelAction],
      intentIdentifiers: [],
      options: []
    )
    UNUserNotificationCenter.current().setNotificationCategories([reminderCategory])
  }

  private func _updateBookingStatus(userId: String, bookingId: String, status: String) {
    guard !userId.isEmpty, !bookingId.isEmpty else { return }
    // Firestore запись через FlutterMethodChannel или напрямую через Firebase iOS SDK
    // Для MVP — отправляем данные в Flutter через NotificationCenter
    NotificationCenter.default.post(
      name: NSNotification.Name("BookingStatusUpdate"),
      object: nil,
      userInfo: ["userId": userId, "bookingId": bookingId, "status": status]
    )
  }
}

// ── MessagingDelegate — обновление FCM токена ─────────────────────────────────
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    // Firebase Flutter SDK подхватит токен автоматически через FirebaseMessaging.onTokenRefresh
  }
}

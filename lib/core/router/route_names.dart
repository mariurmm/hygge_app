// Константы имён и путей маршрутов.

class RouteNames {
  // ── Пути (paths) — используем в context.go() ─────────────────

  static const String splash = '/'; // Сплэш-экран (начальный маршрут).
  static const String login = '/login'; // Экран входа
  static const String main = '/home/main'; // «Главная»
  static const String programs = '/home/programs'; // «Программы»
  static const String profile = '/home/profile'; // «Профиль»
  static const String schedule = '/home/schedule'; // «Расписание»
  static const String history = '/home/history'; // История программ (с профиля)
  static const String settings = '/home/settings'; // Настройки профиля
  static const String homeShell =
      '/homeShell'; // Роут для оболочки с BottomNavigationBar
  static const String notifications = '/notifications'; // Уведомления

  // ── Имена (names) — используем в GoRoute(name: ...) ──────────
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String mainName = 'main';
  static const String profileName = 'profile';
  static const String scheduleName = 'schedule';
  static const String programsName = 'programs';
  static const String historyName = 'history';
  static const String settingsName = 'settings';
  static const String appShellName = 'appShell';
  static const String notificationsName = 'notifications';
}

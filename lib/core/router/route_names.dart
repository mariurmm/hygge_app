// Константы имён и путей маршрутов.

class RouteNames {
  // ── Пути (paths) — используем в context.go() ─────────────────

  static const String splash = '/'; // Сплэш-экран (начальный маршрут).
  static const String login = '/login'; // Экран входа
  static const String main = '/home/main'; // «Главная»
  static const String profile = '/home/profile'; // «Профиль»
  static const String schedule = '/home/schedule'; // «Расписание»

  // ── Имена (names) — используем в GoRoute(name: ...) ──────────
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String mainName = 'main';
  static const String profileName = 'profile';
  static const String scheduleName = 'schedule';
}

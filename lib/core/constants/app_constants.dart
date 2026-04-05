/// Глобальные константы приложения.
///
/// Здесь собраны все «магические» значения, чтобы не разбрасывать
/// числа и строки по коду. Если нужно что-то поменять — меняем
/// только здесь, и изменения подхватятся везде.
class AppConstants {
  // ── Общие ──────────────────────────────────────────────────────
  /// Название приложения (отображается в AppBar, заголовке и т.д.)
  static const String appName = 'Hy.gge';

  // ── Тайминги ───────────────────────────────────────────────────
  /// Сколько секунд показываем сплэш-экран перед переходом.
  static const int splashDelaySeconds = 2;
  static const double splashLogoSize = 200; //size of splah screen icon

  // ── Навигация (индексы вкладок BottomNavigationBar) ────────────
  static const int mainTabIndex = 0; // Главная
  static const int programsTabIndex = 1; // Программы
  static const int scheduleTabIndex = 2; //Расписание
  static const int profileTabIndex  = 3; //Профиль

  // ── Размеры ────────────────────────────────────────────────────
  /// Размер аватара пользователя (радиус CircleAvatar).
  static const double avatarRadius = 48;

  /// Ширина кнопки Google Sign-In.
  static const double googleButtonWidth = 280;

  /// Высота кнопки Google Sign-In.
  static const double googleButtonHeight = 48;

  /// Размер логотипа Google внутри кнопки.
  static const double googleLogoSize = 24;



}

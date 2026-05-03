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
  static const int profileTabIndex = 3; //Профиль

  // ── Размеры ────────────────────────────────────────────────────
  /// Размер аватара пользователя (радиус CircleAvatar).
  static const double avatarRadius = 48;

  /// Ширина кнопки Google Sign-In.
  static const double googleButtonWidth = 280;

  /// Высота кнопки Google Sign-In.
  static const double googleButtonHeight = 48;

  /// Размер логотипа Google внутри кнопки.
  static const double googleLogoSize = 24;

  // ── Programs tab ───────────────────────────────────────────────
  static const double programsFilterWidth = 150;
  static const double programsFilterHeight = 37;
  static const double programsFilterRadius = 35;
  static const double programsCardWidth = 364;
  static const double programsCardHeight = 327;
  static const double programsCardMediaHeight = 205;
  static const double programsCardRadius = 35;
  static const double programsHeaderLogoSize = 32;
  static const double programsHeaderIconSize = 28;
  static const double programsHeaderTitleSize = 20;
  static const double appHeaderHeight = 64;
  static const double programsBlurSigma = 12;
  static const double programsBorderWidth = 1;
  static const double programsCardsBottomInset = 100;
  static const int programsDefaultDurationMin = 30;

  // ── Schedule tab ───────────────────────────────────────────────
  static const double scheduleCardsBottomInset = 100;
  static const double scheduleCardWidth = 373;
  static const double scheduleCardHeight = 135;
  static const double scheduleCardRadius = 35;
  static const double scheduleProgramsIconWidth = 37;
  static const double scheduleProgramsIconHeight = 30.5;
  static const double scheduleProgressStrokeWidth = 316.46;
  static const double scheduleProgressStrokeHeight = 16.24;
  static const double scheduleProgressFillWidth = 225.37;
  static const double scheduleProgressFillHeight = 11;

  // ── Profile tab ────────────────────────────────────────────────
  static const double profileCardsBottomInset = 100;
  static const double profileCardWidth = 373;
  static const double profileAccountCardHeight = 114;
  static const double profileAccountIconSize = 30;
  static const double profileRecentHistoryCardHeight = 200;
  static const double profileAccountDescMaxWidth = 214;
  static const double profileAccountDescMaxHeight = 40;
  static const double profileMonthlyLeftTextMaxWidth = 144;
  static const double profileHistoryTitleMaxWidth = 226;
  static const double profileHistoryTitleMaxHeight = 89;
  static const double profileAccountTextColumnRightInset = 56;

  // ── Settings screen ────────────────────────────────────────────
  static const double settingsHeaderTopSpacing = 43;
  static const double settingsAvatarWidth = 200;
  static const double settingsAvatarHeight = 200;
  static const double settingsGlassRadius = 35;
  static const double settingsAfterAvatarSpacing = 7;
  static const double settingsAfterChangePhotoSpacing = 25;
  static const double settingsLabelInputSpacing = 7;
  static const double settingsAfterEmailSpacing = 25;
  static const double settingsInputWidth = 364;
  static const double settingsInputHeight = 62;
  static const double settingsActionIconSize = 30;
  static const double settingsActionIconTextGap = 12;

  // ── Notifications screen ───────────────────────────────────────
  static const double notificationTileRadius = 20;
  static const double notificationIconSize = 40;
  static const double notificationBadgeSize = 8;

  // ── Контакты «О нас» ───────────────────────────────────────────
  static const String profileContactPhoneDisplay = '+7(777)-777-77-77';
  static const String profileContactPhoneUri = 'tel:+77777777777';
  static const String profileContactEmail = 'hy.gge_concept@gmail.com';
  static const String profileContactEmailUri = 'mailto:hy.gge_concept@gmail.com';
  static const String profileInstagramConceptUrl = 'https://www.instagram.com/hy.gge.concept/';
  static const String profileInstagramBarUrl = 'https://www.instagram.com/hy.gge.specialty.bar/';
  static const String profileMapAddress = 'Казахстан, Алматы, ул. Зенкова, 17';
  static const String profileMapUrl = 'https://maps.app.goo.gl/4bk3WANmFhNcCwXF7';

  static const double notificationButtonSize = 24;

  static const double iconSizeMd = 22;
  static const double iconSizeHero = 56;

  //splash screen
  static const double splashLogoWidth = 500;
  static const double splashLogoHeight = 200;
  static const double splashDotSize = 8;
  static const double splashDotSpacing = 6;
  static const double splashDotScaleMin = 0.4;
  static const double splashDotScaleRange = 0.6;
  static const double splashDotOpacityMin = 0.2;
  static const double splashDotOpacityRange = 0.8;
  static const int splashDotCount = 3;
}

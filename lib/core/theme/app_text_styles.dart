import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Стили текста, используемые в приложении.
///
/// Называем стили по смыслу (headline, body, label),
/// а не по размеру — так проще поддерживать единообразие.
class AppTextStyles {
  // ── Заголовки ──────────────────────────────────────────────────
  /// Крупный заголовок экрана.
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'CeraPro',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Средний заголовок (секции, карточки).
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'CeraPro',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Основной текст ─────────────────────────────────────────────
  /// Обычный текст.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'CeraPro',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Мелкий текст (подписи, детали).
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'CeraPro',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // ── Кнопки и лейблы ───────────────────────────────────────────
  /// Текст на кнопках.
  static const TextStyle button = TextStyle(
    fontFamily: 'CeraPro',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
  );

  /// Мелкий лейбл (чипсы, бейджи).
  static const TextStyle label = TextStyle(
    fontFamily: 'CeraPro',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Programs tab (composed from shared styles, DRY)
  static final TextStyle programsLogo = headlineMedium.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static final TextStyle programsHeading = headlineLarge.copyWith(
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.2,
  );

  static final TextStyle programsSubtitle = bodyLarge.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.white,
    height: 1.2,
  );

  static final TextStyle programsFilter = bodyLarge.copyWith(
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static final TextStyle programsCardTitle = programsFilter;

  static final TextStyle programsCardDescription = bodyLarge.copyWith(
    fontWeight: FontWeight.w300,
    color: Colors.white,
    height: 1.2,
  );

  static final TextStyle scheduleSectionTitle = programsHeading;
  static final TextStyle scheduleDescription = programsSubtitle;
  static final TextStyle scheduleCalendarTitle = bodyLarge.copyWith(
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static final TextStyle scheduleDate = bodyLarge.copyWith(
    color: Colors.white,
  );
  static final TextStyle scheduleCardLabel = bodyLarge.copyWith(
    fontWeight: FontWeight.w300,
    color: Colors.white,
  );
  static final TextStyle scheduleCardTitle = bodyLarge.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static final TextStyle scheduleProgressPercent = bodySmall.copyWith(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: Colors.white,
  );

  // ── Settings screen ────────────────────────────────────────────
  static final TextStyle settingsHeaderTitle = programsHeading.copyWith(
    fontSize: 22,
  );

  static final TextStyle settingsLabel16Light = bodyLarge.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: Colors.white,
    fontFamily: 'CeraPro',
  );

  static final TextStyle settingsInput16Medium = programsFilter.copyWith(
    fontSize: 16,
  );

  static final TextStyle settingsChangePhoto = settingsLabel16Light.copyWith(
    decoration: TextDecoration.underline,
    decorationColor: Colors.white70,
  );

  static const TextStyle settingsActionWhite = TextStyle(
    fontFamily: 'CeraPro',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static final TextStyle settingsActionDelete = settingsActionWhite.copyWith(
    color: AppColors.settingsDeleteText,
  );
}

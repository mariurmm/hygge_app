import 'package:flutter/material.dart';

class AppColors {
  static const Color green = Color(0xFF737B4C); //bar
  static const Color lightBrown = Color(0xFFB78F6B); //concept
  static const Color beige = Color(0xFFEADDCA); //air
  static const Color terracotta = Color(0xFF9E5135); //fire
  static const Color darkBlue = Color(0xFF28374C); //water
  static const Color darkBrown = Color(0xFF7C573D); //earth

  // изменить цвета ниже на наши:

  // ── Основные ───────────────────────────────────────────────────
  /// Главный цвет бренда.
  static const Color primary = Color(0xFF737B4C);

  /// Цвет текста/иконок на primary-фоне.
  static const Color onPrimary = Colors.white;

  /// Вторичный акцентный цвет.
  static const Color secondary = Color(0xFF9E5135);

  /// Цвет текста/иконок на secondary-фоне.
  static const Color onSecondary = Colors.black;


  // ── Фоны ───────────────────────────────────────────────────────
  /// Основной фон экранов.
  static const Color background = Color(0xFFEADDCA);

  /// Фон поверхностей (карточки, bottom sheet и т.д.).
  static const Color surface = Color(0xFFB78F6B);

  /// Цвет ошибок.
  static const Color error = Color(0xFFB3261E);

  // ── Текст ──────────────────────────────────────────────────────
  /// Основной цвет текста.
  static const Color textPrimary = Color(0xFF1C1B1F);

  /// Второстепенный цвет текста (подписи, хинты).
  static const Color textSecondary = Color(0xFF49454F);

  // ── Прочие ─────────────────────────────────────────────────────
  /// Цвет разделителей.
  static const Color divider = Color(0xFFB78F6B);

  /// Цвет неактивных иконок в навигации.
  static const Color inactive = Color(0xFF79747E);

  // ── Programs tab (фильтры) ─────────────────────────────────────
  /// «Все программы» — выбран.
  static const Color programsFilterAllSelected = Color(0xFF2E1B17);

  /// «Медитации» / «Йога» — выбран (#9E5135 @ 25%).
  static const Color programsFilterCategorySelected = Color(0x409E5135);

  /// Любая кнопка фильтра — не выбрана (#D9D9D9 @ 25%).
  static const Color programsFilterUnselected = Color(0x40D9D9D9);
  static const Color programsCard = Color(0xFF5E5F4D);
  static const Color programsCardMedia = Color(0xFF6D6D64);

  // ── Schedule tab ───────────────────────────────────────────────
  static const Color scheduleCard = Color(0xFF5E5E4C);
  static const Color progressStroke = Color(0xFF9E5135);
  static const Color progressFillStart = Color(0xFF737B4C);
  static const Color progressFillEnd = Color(0xFF9E5135);

  /// Полупрозрачный фон карточки «Счёт & подписка» (#D9D9D9 @ 25%).
  static const Color profileAccountCardFill = Color(0x40D9D9D9);

  /// Текст «Удалить аккаунт».
  static const Color settingsDeleteText = Color(0xFFDA4E4E);

  static const Color homeHeadlineAccent = Color(0xFFE08564);
}

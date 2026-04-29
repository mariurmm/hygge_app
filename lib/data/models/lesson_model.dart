import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'localized_value.dart';
import 'master_model.dart';

/// Модель занятия (программа / расписание / история).
class LessonModel extends Equatable {
  /// Уникальный идентификатор.
  final String uuid;

  /// Подзаголовок ритуала (экран расписания).
  final String ritual;

  /// Название занятия.
  final String title;

  /// Описание занятия.
  final String text;

  /// Дата начала.
  final DateTime startDate;

  /// Дата окончания.
  final DateTime finishDate;

  /// Стоимость занятия.
  final double price;

  /// Мастер, ведущий занятие.
  final MasterModel master;

  const LessonModel({
    required this.uuid,
    this.ritual = '',
    required this.title,
    required this.text,
    required this.startDate,
    required this.finishDate,
    required this.price,
    required this.master,
  });

  DateTime get calendarDay =>
      DateTime(startDate.year, startDate.month, startDate.day);

  String scheduleTimeRange() {
    final f = DateFormat('H:mm', 'ru');
    return '${f.format(startDate)} - ${f.format(finishDate)}';
  }

  String scheduleDayLabel(DateTime today) {
    final t = DateTime(today.year, today.month, today.day);
    final d = calendarDay;
    if (d == t) return 'Сегодня';
    if (d == t.add(const Duration(days: 1))) return 'Завтра';
    return DateFormat('d MMM', 'ru').format(d);
  }

  String historyWhenLabel(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = calendarDay;
    final time = DateFormat('H:mm', 'ru').format(startDate);
    if (d == yesterday) return 'Вчера $time';
    if (d == today) return 'Сегодня $time';
    return '${DateFormat('d MMM', 'ru').format(d)} $time';
  }

  static final LessonModel empty = LessonModel(
    uuid: '',
    title: '',
    text: '',
    startDate: DateTime.fromMillisecondsSinceEpoch(0),
    finishDate: DateTime.fromMillisecondsSinceEpoch(0),
    price: 0,
    master: MasterModel.empty,
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  factory LessonModel.fromJson(
    Map<String, dynamic> json, {
    String locale = LocalizedValue.defaultLocale,
  }) {
    return LessonModel(
      uuid: json['uuid'] as String? ?? json['id'] as String? ?? '',
      ritual: LocalizedValue.read(json['ritual'], locale: locale),
      title: LocalizedValue.read(json['title'], locale: locale),
      text: LocalizedValue.read(json['text'], locale: locale),
      startDate: _parseDate(json['startDate']),
      finishDate: _parseDate(json['finishDate']),
      price: _parseDouble(json['price']),
      master: json['master'] is Map
          ? MasterModel.fromJson(
              Map<String, dynamic>.from(json['master'] as Map),
              locale: locale,
            )
          : MasterModel.empty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'ritual': ritual,
      'title': title,
      'text': text,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'price': price,
      'master': master.toJson(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);

    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [
    uuid,
    ritual,
    title,
    text,
    startDate,
    finishDate,
    price,
    master,
  ];
}

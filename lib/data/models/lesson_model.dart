import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class LessonModel extends Equatable {
  final String uuid;
  final String programId;
  final String masterId;
  final DateTime startDate;
  final DateTime finishDate;
  final bool isBookable;

  const LessonModel({
    required this.uuid,
    required this.programId,
    this.masterId = '',
    required this.startDate,
    required this.finishDate,
    this.isBookable = true,
  });

  static final LessonModel empty = LessonModel(
    uuid: '',
    programId: '',
    masterId: '',
    startDate: DateTime.fromMillisecondsSinceEpoch(0),
    finishDate: DateTime.fromMillisecondsSinceEpoch(0),
    isBookable: false,
  );

  DateTime get calendarDay =>
      DateTime(startDate.year, startDate.month, startDate.day);

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  String scheduleTimeRange({String locale = 'ru'}) {
    final formatter = DateFormat('H:mm', locale);
    return '${formatter.format(startDate)} - ${formatter.format(finishDate)}';
  }

  String scheduleDayLabel(DateTime today, {String locale = 'ru'}) {
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final lessonDay = calendarDay;

    if (lessonDay == normalizedToday) return _todayLabel(locale);

    if (lessonDay == normalizedToday.add(const Duration(days: 1))) {
      return _tomorrowLabel(locale);
    }

    return DateFormat('d MMM', locale).format(lessonDay);
  }

  String historyWhenLabel(DateTime now, {String locale = 'ru'}) {
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lessonDay = calendarDay;
    final time = DateFormat('H:mm', locale).format(startDate);

    if (lessonDay == yesterday) return '${_yesterdayLabel(locale)} $time';
    if (lessonDay == today) return '${_todayLabel(locale)} $time';

    return '${DateFormat('d MMM', locale).format(lessonDay)} $time';
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      uuid: json['uuid'] as String? ?? json['id'] as String? ?? '',
      programId: json['programId'] as String? ?? '',
      masterId: json['masterId'] as String? ?? '',
      startDate: _parseDate(json['startDate'] ?? json['availableFrom']),
      finishDate: _parseDate(
        json['finishDate'] ?? json['endDate'] ?? json['availableTo'],
      ),
      isBookable: json['isBookable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'programId': programId,
      'masterId': masterId,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'isBookable': isBookable,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;

    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  static String _todayLabel(String locale) {
    return switch (locale) {
      'kk' => 'Бүгін',
      'en' => 'Today',
      _ => 'Сегодня',
    };
  }

  static String _tomorrowLabel(String locale) {
    return switch (locale) {
      'kk' => 'Ертең',
      'en' => 'Tomorrow',
      _ => 'Завтра',
    };
  }

  static String _yesterdayLabel(String locale) {
    return switch (locale) {
      'kk' => 'Кеше',
      'en' => 'Yesterday',
      _ => 'Вчера',
    };
  }

  @override
  List<Object?> get props => [
    uuid,
    programId,
    masterId,
    startDate,
    finishDate,
    isBookable,
  ];
}

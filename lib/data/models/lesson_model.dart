import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../../core/utils/parse_utils.dart';

class LessonModel extends Equatable {
  final String id;
  final String programId;
  final String trainerId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isBookable;

  const LessonModel({
    required this.id,
    required this.programId,
    this.trainerId = '',
    required this.startDate,
    required this.endDate,
    this.isBookable = true,
  });

  static final LessonModel empty = LessonModel(
    id: '',
    programId: '',
    trainerId: '',
    startDate: DateTime.fromMillisecondsSinceEpoch(0),
    endDate: DateTime.fromMillisecondsSinceEpoch(0),
    isBookable: false,
  );

  DateTime get calendarDay => DateTime(startDate.year, startDate.month, startDate.day);

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  String scheduleTimeRange({String locale = 'ru'}) {
    final formatter = DateFormat('H:mm', locale);
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
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
      id: json['uuid'] as String? ?? json['id'] as String? ?? '',
      programId: json['programId'] as String? ?? '',
      trainerId: json['masterId'] as String? ?? '',
      startDate: ParseUtils.parseDate(json['startDate'] ?? json['availableFrom']),
      endDate: ParseUtils.parseDate(json['finishDate'] ?? json['endDate'] ?? json['availableTo']),
      isBookable: json['isBookable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'programId': programId,
      'masterId': trainerId,
      'startDate': startDate.toIso8601String(),
      'finishDate': endDate.toIso8601String(),
      'isBookable': isBookable,
    };
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
  List<Object?> get props => [id, programId, trainerId, startDate, endDate, isBookable];
}

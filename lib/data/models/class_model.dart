import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hygge_app/core/utils/parse_utils.dart';
import 'package:intl/intl.dart';

part 'class_model.freezed.dart';

@freezed
abstract class ClassModel with _$ClassModel {
  const factory ClassModel({
    required String id,
    required String title,
    required String type,
    required DateTime startDate,
    required int durationMinutes,
    required String trainerId,
    required int maxParticipants,
    required int currentParticipants,
    required double price,
    required bool isIncludedInSubscription,
    /// ID программы в коллекции Firestore `programs`.
    /// Используется для открытия страницы деталей программы из расписания.
    @Default('') String programId,
  }) = _ClassModel;

  const ClassModel._();

  factory ClassModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ClassModel(
      id: id ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      startDate: ParseUtils.parseDate(json['datetime']),
      durationMinutes: ParseUtils.parseInt(json['durationMinutes']),
      trainerId: json['trainerId'] as String? ?? '',
      maxParticipants: ParseUtils.parseInt(json['maxParticipants']),
      currentParticipants: ParseUtils.parseInt(json['currentParticipants']),
      price: ParseUtils.parseDouble(json['price']),
      isIncludedInSubscription:
          json['isIncludedInSubscription'] as bool? ?? true,
      programId: json['programId'] as String? ?? '',
    );
  }

  bool get isFull => currentParticipants >= maxParticipants;

  DateTime get endTime => startDate.add(Duration(minutes: durationMinutes));

  String get timeRange {
    final f = DateFormat('H:mm', 'ru');
    return '${f.format(startDate)} – ${f.format(endTime)}';
  }

  String dayLabel(DateTime today) {
    final t = DateTime(today.year, today.month, today.day);
    final d = DateTime(startDate.year, startDate.month, startDate.day);
    if (d == t) return 'Сегодня';
    if (d == t.add(const Duration(days: 1))) return 'Завтра';
    return DateFormat('d MMM', 'ru').format(d);
  }

  DateTime get calendarDay =>
      DateTime(startDate.year, startDate.month, startDate.day);

  static final ClassModel empty = ClassModel(
    id: '',
    title: '',
    type: '',
    startDate: DateTime.fromMillisecondsSinceEpoch(0),
    durationMinutes: 0,
    trainerId: '',
    maxParticipants: 0,
    currentParticipants: 0,
    price: 0,
    isIncludedInSubscription: true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'datetime': Timestamp.fromDate(startDate),
    'durationMinutes': durationMinutes,
    'trainerId': trainerId,
    'maxParticipants': maxParticipants,
    'currentParticipants': currentParticipants,
    'price': price,
    'isIncludedInSubscription': isIncludedInSubscription,
    'programId': programId,
  };
}

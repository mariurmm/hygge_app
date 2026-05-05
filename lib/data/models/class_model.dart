import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/core/utils/parse_utils.dart';
import 'package:intl/intl.dart';

class ClassModel extends Equatable {
  const ClassModel({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    required this.durationMinutes,
    required this.trainerId,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.price,
    required this.isIncludedInSubscription,
  });

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
    );
  }
  final String id;
  final String title;
  final String type;
  final DateTime startDate;
  final int durationMinutes;
  final String trainerId;
  final int maxParticipants;
  final int currentParticipants;
  final double price;
  final bool isIncludedInSubscription;

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
  };

  ClassModel copyWith({
    String? id,
    String? title,
    String? type,
    DateTime? startDate,
    int? durationMinutes,
    String? trainerId,
    int? maxParticipants,
    int? currentParticipants,
    double? price,
    bool? isIncludedInSubscription,
  }) {
    return ClassModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      trainerId: trainerId ?? this.trainerId,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      price: price ?? this.price,
      isIncludedInSubscription:
          isIncludedInSubscription ?? this.isIncludedInSubscription,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    startDate,
    durationMinutes,
    trainerId,
    maxParticipants,
    currentParticipants,
    price,
    isIncludedInSubscription,
  ];
}

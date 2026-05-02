import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class ClassModel extends Equatable {
  final String id;
  final String title;
  final String type;
  final DateTime datetime;
  final int durationMinutes;
  final String trainerId;
  final int maxParticipants;
  final int currentParticipants;
  final double price;
  final bool isIncludedInSubscription;

  const ClassModel({
    required this.id,
    required this.title,
    required this.type,
    required this.datetime,
    required this.durationMinutes,
    required this.trainerId,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.price,
    required this.isIncludedInSubscription,
  });

  bool get isFull => currentParticipants >= maxParticipants;

  DateTime get endTime => datetime.add(Duration(minutes: durationMinutes));

  String get timeRange {
    final f = DateFormat('H:mm', 'ru');
    return '${f.format(datetime)} – ${f.format(endTime)}';
  }

  String dayLabel(DateTime today) {
    final t = DateTime(today.year, today.month, today.day);
    final d = DateTime(datetime.year, datetime.month, datetime.day);
    if (d == t) return 'Сегодня';
    if (d == t.add(const Duration(days: 1))) return 'Завтра';
    return DateFormat('d MMM', 'ru').format(d);
  }

  DateTime get calendarDay =>
      DateTime(datetime.year, datetime.month, datetime.day);

  static final ClassModel empty = ClassModel(
    id: '',
    title: '',
    type: '',
    datetime: DateTime.fromMillisecondsSinceEpoch(0),
    durationMinutes: 0,
    trainerId: '',
    maxParticipants: 0,
    currentParticipants: 0,
    price: 0,
    isIncludedInSubscription: true,
  );

  factory ClassModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ClassModel(
      id: id ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      datetime: _parseDate(json['datetime']),
      durationMinutes: _parseInt(json['durationMinutes']),
      trainerId: json['trainerId'] as String? ?? '',
      maxParticipants: _parseInt(json['maxParticipants']),
      currentParticipants: _parseInt(json['currentParticipants']),
      price: _parseDouble(json['price']),
      isIncludedInSubscription:
          json['isIncludedInSubscription'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'datetime': Timestamp.fromDate(datetime),
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
    DateTime? datetime,
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
      datetime: datetime ?? this.datetime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      trainerId: trainerId ?? this.trainerId,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      price: price ?? this.price,
      isIncludedInSubscription:
          isIncludedInSubscription ?? this.isIncludedInSubscription,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        datetime,
        durationMinutes,
        trainerId,
        maxParticipants,
        currentParticipants,
        price,
        isIncludedInSubscription,
      ];
}

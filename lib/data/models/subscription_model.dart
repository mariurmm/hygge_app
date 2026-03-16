import 'package:equatable/equatable.dart';

/// Модель абонемента.
class SubscriptionModel extends Equatable {
  /// Уникальный идентификатор.
  final String uuid;

  /// Название абонемента.
  final String title;

  /// Стоимость.
  final double price;

  /// Дата начала.
  final DateTime startDate;

  /// Дата окончания.
  final DateTime finishDate;

  /// Количество занятий.
  final int lessonsCount;

  const SubscriptionModel({
    required this.uuid,
    required this.title,
    required this.price,
    required this.startDate,
    required this.finishDate,
    required this.lessonsCount,
  });

  /// Пустая модель.
  static final SubscriptionModel empty = SubscriptionModel(
    uuid: '',
    title: '',
    price: 0,
    startDate: DateTime.fromMillisecondsSinceEpoch(0),
    finishDate: DateTime.fromMillisecondsSinceEpoch(0),
    lessonsCount: 0,
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: _parseDouble(json['price']),
      startDate: _parseDate(json['startDate']),
      finishDate: _parseDate(json['finishDate']),
      lessonsCount: _parseInt(json['lessonsCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'price': price,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'lessonsCount': lessonsCount,
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

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [
        uuid,
        title,
        price,
        startDate,
        finishDate,
        lessonsCount,
      ];
}

import 'package:equatable/equatable.dart';

import 'master_model.dart';

/// Модель занятия.
class LessonModel extends Equatable {
  /// Уникальный идентификатор.
  final String uuid;

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
    required this.title,
    required this.text,
    required this.startDate,
    required this.finishDate,
    required this.price,
    required this.master,
  });

  /// Пустая модель.
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

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      startDate: _parseDate(json['startDate']),
      finishDate: _parseDate(json['finishDate']),
      price: _parseDouble(json['price']),
      master: json['master'] is Map<String, dynamic>
          ? MasterModel.fromJson(json['master'] as Map<String, dynamic>)
          : MasterModel.empty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
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
        title,
        text,
        startDate,
        finishDate,
        price,
        master,
      ];
}

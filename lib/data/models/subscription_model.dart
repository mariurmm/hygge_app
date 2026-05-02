import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SubscriptionModel extends Equatable {
  final String id;
  final String userId;
  final int totalSessions;
  final int usedSessions;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.totalSessions,
    required this.usedSessions,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  int get remainingSessions => totalSessions - usedSessions;
  bool get isExpired => endDate.isBefore(DateTime.now());
  bool get isValid => isActive && !isExpired && remainingSessions > 0;

  static final SubscriptionModel empty = SubscriptionModel(
    id: '',
    userId: '',
    totalSessions: 0,
    usedSessions: 0,
    startDate: DateTime.fromMillisecondsSinceEpoch(0),
    endDate: DateTime.fromMillisecondsSinceEpoch(0),
    isActive: false,
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => !isEmpty;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      totalSessions: _parseInt(json['totalSessions']),
      usedSessions: _parseInt(json['usedSessions']),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'totalSessions': totalSessions,
        'usedSessions': usedSessions,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'isActive': isActive,
      };

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    int? totalSessions,
    int? usedSessions,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalSessions: totalSessions ?? this.totalSessions,
      usedSessions: usedSessions ?? this.usedSessions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
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

  @override
  List<Object?> get props =>
      [id, userId, totalSessions, usedSessions, startDate, endDate, isActive];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/utils/parse_utils.dart';

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
      totalSessions: ParseUtils.parseInt(json['totalSessions']),
      usedSessions: ParseUtils.parseInt(json['usedSessions']),
      startDate: ParseUtils.parseDate(json['startDate']),
      endDate: ParseUtils.parseDate(json['endDate']),
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

  @override
  List<Object?> get props => [
    id,
    userId,
    totalSessions,
    usedSessions,
    startDate,
    endDate,
    isActive,
  ];
}

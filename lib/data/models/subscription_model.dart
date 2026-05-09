import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:hygge_app/core/utils/parse_utils.dart';

part 'subscription_model.freezed.dart';

@freezed
abstract class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    required String userId,
    required int totalSessions,
    required int usedSessions,
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
  }) = _SubscriptionModel;

  const SubscriptionModel._();

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'totalSessions': totalSessions,
    'usedSessions': usedSessions,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'isActive': isActive,
  };
}

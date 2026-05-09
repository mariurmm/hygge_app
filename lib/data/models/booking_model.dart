import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:hygge_app/core/utils/parse_utils.dart';

part 'booking_model.freezed.dart';

enum BookingStatus { pending, confirmed, cancelled }

@freezed
abstract class BookingModel with _$BookingModel {
  const factory BookingModel({
    required String id,
    required String userId,
    required String classId,
    required DateTime datetime,
    required BookingStatus status,
    required bool notificationSent,
  }) = _BookingModel;

  const BookingModel._();

  factory BookingModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return BookingModel(
      id: id ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      classId: json['classId'] as String? ?? '',
      datetime: ParseUtils.parseDate(json['datetime']),
      status: _parseStatus(json['status']),
      notificationSent: json['notificationSent'] as bool? ?? false,
    );
  }

  bool get isPending => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;

  static final BookingModel empty = BookingModel(
    id: '',
    userId: '',
    classId: '',
    datetime: DateTime.fromMillisecondsSinceEpoch(0),
    status: BookingStatus.pending,
    notificationSent: false,
  );

  bool get isEmpty => this == empty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'classId': classId,
    'datetime': Timestamp.fromDate(datetime),
    'status': status.name,
    'notificationSent': notificationSent,
  };

  static BookingStatus _parseStatus(dynamic value) {
    switch (value as String?) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

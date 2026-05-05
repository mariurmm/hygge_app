import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/utils/parse_utils.dart';

enum BookingStatus { pending, confirmed, cancelled }

class BookingModel extends Equatable {
  final String id;
  final String userId;
  final String classId;
  final DateTime datetime;
  final BookingStatus status;
  final bool notificationSent;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.classId,
    required this.datetime,
    required this.status,
    required this.notificationSent,
  });

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'classId': classId,
    'datetime': Timestamp.fromDate(datetime),
    'status': status.name,
    'notificationSent': notificationSent,
  };

  BookingModel copyWith({
    String? id,
    String? userId,
    String? classId,
    DateTime? datetime,
    BookingStatus? status,
    bool? notificationSent,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      classId: classId ?? this.classId,
      datetime: datetime ?? this.datetime,
      status: status ?? this.status,
      notificationSent: notificationSent ?? this.notificationSent,
    );
  }

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

  @override
  List<Object?> get props => [
    id,
    userId,
    classId,
    datetime,
    status,
    notificationSent,
  ];
}

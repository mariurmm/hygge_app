import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared JSON/dynamic parsing helpers used by data models.
///
/// Each method accepts any dynamic input and never throws —
/// unrecognised values fall back to a sensible default.
class ParseUtils {
  ParseUtils._();

  /// Converts Firestore [Timestamp], [DateTime], ISO-8601 [String], or a
  /// millisecond [int] to [DateTime].  Falls back to the Unix epoch.
  static DateTime parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    // Handles any object with a .toDate() method (e.g. Firestore Timestamp
    // arriving as dynamic when the import is missing).
    try {
      // Handles any object with a .toDate() method (e.g. Firestore Timestamp
      // arriving as dynamic when the import is missing).
      // ignore: avoid_dynamic_calls
      return (value as dynamic).toDate() as DateTime;
    } on Object {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  /// Converts [num] or a numeric [String] to [int]. Returns [fallback] on failure.
  static int parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  /// Converts [num] or a numeric [String] to [double]. Returns [fallback] on failure.
  static double parseDouble(dynamic value, {double fallback = 0.0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

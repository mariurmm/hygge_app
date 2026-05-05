import 'package:flutter_test/flutter_test.dart';
import 'package:hygge_app/core/utils/parse_utils.dart';

void main() {
  final epoch = DateTime.fromMillisecondsSinceEpoch(0);

  // ── parseDate ─────────────────────────────────────────────────────────────

  group('ParseUtils.parseDate', () {
    test('returns the same DateTime when given a DateTime', () {
      final dt = DateTime(2024, 6, 15, 10, 30);
      expect(ParseUtils.parseDate(dt), dt);
    });

    test('parses a valid ISO-8601 string', () {
      expect(
        ParseUtils.parseDate('2024-06-15T10:30:00.000'),
        DateTime(2024, 6, 15, 10, 30),
      );
    });

    test('converts a millisecond int to DateTime', () {
      final ms = DateTime(2024).millisecondsSinceEpoch;
      expect(ParseUtils.parseDate(ms), DateTime(2024));
    });

    test('returns epoch for null', () {
      expect(ParseUtils.parseDate(null), epoch);
    });

    test('returns epoch for an empty string', () {
      expect(ParseUtils.parseDate(''), epoch);
    });

    test('returns epoch for an unparseable string', () {
      expect(ParseUtils.parseDate('not-a-date'), epoch);
    });

    test('returns epoch for an unrecognised type', () {
      expect(ParseUtils.parseDate(Object()), epoch);
    });
  });

  // ── parseInt ──────────────────────────────────────────────────────────────

  group('ParseUtils.parseInt', () {
    test('returns the int directly', () {
      expect(ParseUtils.parseInt(42), 42);
    });

    test('truncates a double to int', () {
      expect(ParseUtils.parseInt(3.9), 3);
    });

    test('parses a numeric string', () {
      expect(ParseUtils.parseInt('7'), 7);
    });

    test('returns the default fallback (0) for null', () {
      expect(ParseUtils.parseInt(null), 0);
    });

    test('returns a custom fallback for non-numeric input', () {
      expect(ParseUtils.parseInt('abc', fallback: -1), -1);
    });
  });

  // ── parseDouble ───────────────────────────────────────────────────────────

  group('ParseUtils.parseDouble', () {
    test('returns a double directly', () {
      expect(ParseUtils.parseDouble(3.14), 3.14);
    });

    test('promotes an int to double', () {
      expect(ParseUtils.parseDouble(5), 5.0);
    });

    test('parses a decimal string', () {
      expect(ParseUtils.parseDouble('2.5'), 2.5);
    });

    test('returns the default fallback (0.0) for null', () {
      expect(ParseUtils.parseDouble(null), 0.0);
    });

    test('returns a custom fallback for non-numeric input', () {
      expect(ParseUtils.parseDouble('bad', fallback: -1), -1.0);
    });
  });
}

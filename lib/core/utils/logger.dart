import 'package:hygge_app/core/logging/sentry_log_output.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
    output: SentryLogOutput(),
  );

  /// Информационное сообщение
  static void info(String message) {
    _logger.i(message);
  }

  /// Предупреждение
  static void warning(String message) {
    _logger.w(message);
  }

  /// Ошибка
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Debug (полезно для разработки)
  static void debug(String message) {
    _logger.d(message);
  }
}

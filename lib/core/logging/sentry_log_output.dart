import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Forwards error-level log events to Sentry while also writing every line to
/// the standard console via [ConsoleOutput].
class SentryLogOutput extends LogOutput {
  final LogOutput _console = ConsoleOutput();

  @override
  void output(OutputEvent event) {
    _console.output(event);
    if (event.level.index >= Level.error.index) {
      //Sentry.captureMessage returns a future that is intentionally not awaited
      // because LogOutput.output() is synchronous.
      // ignore: discarded_futures
      Sentry.captureMessage(event.lines.join('\n'), level: SentryLevel.error);
    }
  }
}

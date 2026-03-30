import "package:flutter/foundation.dart";
import "package:logger/logger.dart";

/// Uygulama geneli loglama. Üretimde [ProductionFilter] ile gürültü azaltılır.
class AppLogger {
  AppLogger._();

  static Logger? _logger;

  static void init() {
    _logger ??= Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 100,
        colors: !kReleaseMode,
        printEmojis: !kReleaseMode,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  static Logger get _l {
    init();
    return _logger!;
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _l.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _l.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _l.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _l.e(message, error: error, stackTrace: stackTrace);
  }
}

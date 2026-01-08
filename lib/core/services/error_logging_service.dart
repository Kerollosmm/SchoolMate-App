import 'package:flutter/foundation.dart';

abstract class ErrorLoggingService {
  Future<void> logError(dynamic error, StackTrace? stackTrace);
  Future<void> logMessage(String message);
}

class ConsoleErrorLoggingService implements ErrorLoggingService {
  @override
  Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    debugPrint('🔴 ERROR: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace:\n$stackTrace');
    }
  }

  @override
  Future<void> logMessage(String message) async {
    debugPrint('🔵 LOG: $message');
  }
}

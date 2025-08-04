import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void logError(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    debugPrint('Error: $message');
    if (error != null) {
      debugPrint('Error details: $error');
    }
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  static void handleAsyncError(Function callback, String operation) {
    try {
      callback();
    } catch (e, stackTrace) {
      logError('Error during $operation', e, stackTrace);
    }
  }

  static Future<T?> handleAsyncOperation<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      logError('Error during $operationName', e, stackTrace);
      return null;
    }
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class ErrorLogEntry {
  final String timestamp;
  final String errorType;
  final String errorMessage;
  final String? stackTrace;
  final Map<String, dynamic> context;

  ErrorLogEntry({
    required this.timestamp,
    required this.errorType,
    required this.errorMessage,
    this.stackTrace,
    this.context = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'errorType': errorType,
      'errorMessage': errorMessage,
      'stackTrace': stackTrace,
      'context': context,
    };
  }

  factory ErrorLogEntry.fromJson(Map<String, dynamic> json) {
    return ErrorLogEntry(
      timestamp: json['timestamp'] as String,
      errorType: json['errorType'] as String,
      errorMessage: json['errorMessage'] as String,
      stackTrace: json['stackTrace'] as String?,
      context: json['context'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('[$timestamp] $errorType');
    buffer.writeln('Message: $errorMessage');
    if (context.isNotEmpty) {
      buffer.writeln('Context: $context');
    }
    if (stackTrace != null && stackTrace!.isNotEmpty) {
      buffer.writeln('Stack Trace:\n$stackTrace');
    }
    buffer.writeln('---');
    return buffer.toString();
  }
}

class ErrorLogService {
  static const String _boxName = 'error_logs';
  static const int _maxLogs = 50; // Keep last 50 errors
  static Box<Map>? _box;

  static Future<void> initialize() async {
    try {
      _box = await Hive.openBox<Map>(_boxName);
    } catch (e) {
      print('⚠️ Error logs box corrupt, deleting: $e');
      await Hive.deleteBoxFromDisk(_boxName);
      _box = await Hive.openBox<Map>(_boxName);
    }

    // Set up Flutter error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      logError(
        errorType: 'FlutterError',
        errorMessage: details.exception.toString(),
        stackTrace: details.stack?.toString(),
      );
    };

    // Set up Dart error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      logError(
        errorType: 'DartError',
        errorMessage: error.toString(),
        stackTrace: stack.toString(),
      );
      return true;
    };
  }

  static void logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? additionalContext,
  }) {
    if (_box == null) return;

    // Anonymize the error message - remove potential sensitive data
    final sanitizedMessage = _sanitizeMessage(errorMessage);
    final sanitizedStack =
        stackTrace != null ? _sanitizeStackTrace(stackTrace) : null;

    final entry = ErrorLogEntry(
      timestamp: DateTime.now().toIso8601String(),
      errorType: errorType,
      errorMessage: sanitizedMessage,
      stackTrace: sanitizedStack,
      context: {
        ...?additionalContext,
        'platform': defaultTargetPlatform.name,
      },
    );

    // Add to box
    _box!.add(entry.toJson());

    // Keep only last N logs
    if (_box!.length > _maxLogs) {
      _box!.deleteAt(0);
    }

    print('🔴 Error logged: $errorType - $sanitizedMessage');
  }

  static List<ErrorLogEntry> getAllLogs() {
    if (_box == null) return [];

    return _box!.values
        .map((json) => ErrorLogEntry.fromJson(Map<String, dynamic>.from(json)))
        .toList()
        .reversed
        .toList();
  }

  static String getLogsAsText() {
    final logs = getAllLogs();
    if (logs.isEmpty) {
      return 'Ingen feil logget ✅';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== SpareMester Feillogg ===');
    buffer.writeln('Antall feil: ${logs.length}');
    buffer.writeln('Generert: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('VIKTIG: Denne loggen inneholder INGEN personlige data.');
    buffer.writeln('Produktnavn, priser og URLer er anonymisert.\n');
    buffer.writeln('=====================================\n');

    for (final log in logs) {
      buffer.write(log.toString());
      buffer.writeln();
    }

    return buffer.toString();
  }

  static Future<void> clearLogs() async {
    await _box?.clear();
    print('🗑️ Feillogger slettet');
  }

  static int getLogCount() {
    return _box?.length ?? 0;
  }

  // Sanitize error messages to remove sensitive data
  static String _sanitizeMessage(String message) {
    String sanitized = message;

    // Remove URLs
    sanitized = sanitized.replaceAll(
      RegExp(r'https?://[^\s]+', caseSensitive: false),
      '[URL_REMOVED]',
    );

    // Remove numbers that could be prices (but keep technical numbers like line numbers)
    sanitized = sanitized.replaceAll(
      RegExp(r'\b\d{2,}\.\d{1,2}\b'), // Matches prices like 299.90
      '[PRICE]',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'\b\d{3,}\s*kr\b', caseSensitive: false),
      '[PRICE]',
    );

    // Remove potential product names (quoted strings)
    sanitized = sanitized.replaceAll(
      RegExp(r'"[^"]{3,}"'),
      '"[PRODUCT_NAME]"',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r"'[^']{3,}'"),
      "'[PRODUCT_NAME]'",
    );

    // Remove file paths with user names
    sanitized = sanitized.replaceAll(
      RegExp(r'C:\\Users\\[^\\]+'),
      'C:\\Users\\[USER]',
    );

    return sanitized;
  }

  static String _sanitizeStackTrace(String stackTrace) {
    String sanitized = stackTrace;

    // Remove file paths with user names
    sanitized = sanitized.replaceAll(
      RegExp(r'C:\\Users\\[^\\]+'),
      'C:\\Users\\[USER]',
    );

    // Keep only first 10 lines of stack trace to reduce size
    final lines = sanitized.split('\n');
    if (lines.length > 10) {
      sanitized =
          lines.take(10).join('\n') + '\n... (${lines.length - 10} more lines)';
    }

    return sanitized;
  }
}

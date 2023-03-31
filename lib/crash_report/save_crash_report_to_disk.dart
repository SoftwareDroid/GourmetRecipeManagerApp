import 'package:f_logs/f_logs.dart';

class CrashReporter {
  static bool DEBUG_MODE = true;

  static Future<void> reportError(dynamic error, dynamic stackTrace) async {
    if (DEBUG_MODE) {
      // Print the full stacktrace in debug mode.
      print(stackTrace);
    } else {

      FLog.logThis(
          text: "Catched Error",
          type: LogLevel.SEVERE,
          exception: error,
          stacktrace: stackTrace);
    }

  }

}
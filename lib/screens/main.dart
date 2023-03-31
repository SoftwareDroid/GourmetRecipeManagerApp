import 'dart:async';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:recipe_searcher/screens/view_welcome_screen.dart';
import 'package:recipe_searcher/crash_report/save_crash_report_to_disk.dart';

// TODO new App name GourmetFoodSuggester
void main() {
  CrashReporter.DEBUG_MODE = false;
  // Set up Logging
  LogsConfig config = FLog.getDefaultConfigurations()
    ..isDevelopmentDebuggingEnabled = true
    ..timestampFormat = TimestampFormat.TIME_FORMAT_FULL_2;
  FLog.applyConfigurations(config);
  // Catch Errors and Exceptions
  runZoned<Future<void>>(() async {
    runApp(new MyApp());
  }, onError: (error, stackTrace) async {
    await CrashReporter.reportError(error, stackTrace);

  });
}

class MyApp extends StatelessWidget {

  @override
  void initState() {

    //findSystemLocale();
  }
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Generated App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196f3),
        accentColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: new ViewWelcomeScreen(),
    );
  }
}


import 'package:flutter/material.dart';
import 'debug_calendar.dart';

void main() {
  runApp(const DebugApp());
}

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Calendar',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DebugCalendar(),
      debugShowCheckedModeBanner: false,
    );
  }
}

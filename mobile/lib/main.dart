import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const CalorieBrApp());
}

class CalorieBrApp extends StatelessWidget {
  const CalorieBrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalorieBR AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

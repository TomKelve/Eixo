import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EixoApp());
}

class EixoApp extends StatelessWidget {
  const EixoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EIXO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

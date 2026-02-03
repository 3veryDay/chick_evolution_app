import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const ChickEvolutionApp());
}

class ChickEvolutionApp extends StatelessWidget {
  const ChickEvolutionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '신입 병아리 진화',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

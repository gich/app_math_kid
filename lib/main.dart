import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MathKidApp());
}

class MathKidApp extends StatelessWidget {
  const MathKidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multiplication Trainer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

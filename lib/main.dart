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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.pink.shade100,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.pink.shade100,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.pink.shade100,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

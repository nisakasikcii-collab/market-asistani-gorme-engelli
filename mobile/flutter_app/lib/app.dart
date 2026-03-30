import "package:flutter/material.dart";

import "app_entry.dart";

class EsApp extends StatelessWidget {
  const EsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dark gray background (#3A3A3A) + Yellow (#FFC107) accent
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFC107), // Yellow
        brightness: Brightness.dark,
        surface: const Color(0xFF2A2A2A), // Dark gray surface
        surfaceContainer: const Color(0xFF3A3A3A), // Slightly lighter gray
        onSurface: const Color(0xFFFFFFFF), // White text on dark
      ),
    );

    return MaterialApp(
      title: "Eyeshopper AI",
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFF2A2A2A),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107), // Yellow
            foregroundColor: const Color(0xFF2A2A2A), // Dark text on yellow
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color(0xFF3A3A3A),
          foregroundColor: const Color(0xFFFFFFFF),
        ),
      ),
      home: const AppEntry(),
    );
  }
}

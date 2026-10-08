import 'package:flutter/material.dart';

/// Tema escolhido pelo usuário (Claro, Automático ou Escuro).
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

const Color _seed = Color(0xFF4F46E5);
const Color _darkBackground = Color(0xFF030A14);
const Color _darkCard = Color(0xFF0A1624);
const Color _darkCardHigh = Color(0xFF10203A);
const Color _darkBorder = Color(0xFF1C2B42);

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  ).copyWith(
    surface: _darkBackground,
    surfaceContainerLowest: _darkBackground,
    surfaceContainerLow: _darkCard,
    surfaceContainer: _darkCard,
    surfaceContainerHigh: _darkCardHigh,
    surfaceContainerHighest: _darkCardHigh,
    outlineVariant: _darkBorder,
  );
  return _base(scheme).copyWith(scaffoldBackgroundColor: _darkBackground);
}

ThemeData buildLightTheme() {
  return _base(ColorScheme.fromSeed(seedColor: _seed));
}

ThemeData _base(ColorScheme scheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}

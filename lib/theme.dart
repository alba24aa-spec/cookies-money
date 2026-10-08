import 'package:flutter/material.dart';

/// Paleta pastel azul-amarillo sacada del tarro de galletas.
class CM {
  static const bg = Color(0xFFFCF9EF);
  static const sky = Color(0xFFD6E9F6);
  static const skyDeep = Color(0xFF8FBEDC);
  static const butter = Color(0xFFFFF1B8);
  static const butterDeep = Color(0xFFF1D777);
  static const ink = Color(0xFF2F3B47);
  static const orange = Color(0xFFFF8A2B);
  static const charcoal = Color(0xFF212327);
  static const teal = Color(0xFF63B5C6);
  static const alert = Color(0xFFE5484D); // solo alertas

  static ThemeData theme() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: skyDeep, surface: bg),
        scaffoldBackgroundColor: bg,
        appBarTheme: const AppBarTheme(
            backgroundColor: bg, foregroundColor: ink, elevation: 0,
            scrolledUnderElevation: 0),
        textTheme: ThemeData.light().textTheme
            .apply(bodyColor: ink, displayColor: ink),
      );
}

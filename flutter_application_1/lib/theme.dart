import 'package:flutter/material.dart';

/// Paleta de SyncPlay. Cambia aquí un color y se actualiza en toda la app.
class C {
  static const bg = Color(0xFF0A0D16);
  static const surface = Color(0xFF111726);
  static const surfaceHi = Color(0xFF161D30);
  static const border = Color(0xFF1F2840);
  static const primary = Color(0xFF7B6CFF);
  static const primarySoft = Color(0x337B6CFF);
  static const online = Color(0xFF3DDC84);
  static const text = Color(0xFFE8EAF2);
  static const muted = Color(0xFF8A93AB);
  static const amber = Color(0xFFFFC24B);
}

ThemeData buildTheme() => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: C.bg,
      colorScheme: const ColorScheme.dark(primary: C.primary),
      useMaterial3: true,
    );

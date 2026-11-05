import 'package:flutter/material.dart';

class AerionColors {
  AerionColors._();

  // Dark Navy / Charcoal Palette
  static const Color darkBackground = Color(0xFF0A0E17);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1A2234);
  static const Color darkCardBorder = Color(0xFF243048);

  // Soft Cyan and Electric Blue Accents
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color electricBlue = Color(0xFF0070F3);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color crimsonAlert = Color(0xFFEF4444);

  // Light Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightCardBorder = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00E5FF),
      Color(0xFF0070F3),
    ],
  );

  static const LinearGradient tempGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF7A00),
      Color(0xFFFF0055),
    ],
  );

  static const LinearGradient humidityGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00E5FF),
      Color(0xFF0284C7),
    ],
  );
}

class AerionTheme {
  AerionTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AerionColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AerionColors.cyanAccent,
        secondary: AerionColors.electricBlue,
        surface: AerionColors.darkSurface,
        error: AerionColors.crimsonAlert,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AerionColors.textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AerionColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AerionColors.textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: AerionColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AerionColors.darkCardBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AerionColors.darkSurface,
        selectedItemColor: AerionColors.cyanAccent,
        unselectedItemColor: AerionColors.textMutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AerionColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AerionColors.electricBlue,
        secondary: AerionColors.cyanAccent,
        surface: AerionColors.lightSurface,
        error: AerionColors.crimsonAlert,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AerionColors.textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AerionColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AerionColors.textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: AerionColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AerionColors.lightCardBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AerionColors.lightSurface,
        selectedItemColor: AerionColors.electricBlue,
        unselectedItemColor: AerionColors.textMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

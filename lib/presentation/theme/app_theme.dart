import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Shared colors
  static const Color _primaryBlue = Color(0xFF2196F3);

  // Dark colors
  static const Color _surfaceDark = Color(0xFF0A1628);
  static const Color _cardDark = Color(0xFF142038);
  static const Color _textPrimaryDark = Color(0xFFECF0F1);
  static const Color _textSecondaryDark = Color(0xFFB0BEC5);

  // Light colors
  static const Color _surfaceLight = Color(0xFFF0F4FF);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _textPrimaryLight = Color(0xFF1A237E);
  static const Color _textSecondaryLight = Color(0xFF546E7A);

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final surfaceColor = isDark ? _surfaceDark : _surfaceLight;
    final cardColor = isDark ? _cardDark : _cardLight;
    final textPrimary = isDark ? _textPrimaryDark : _textPrimaryLight;
    final textSecondary = isDark ? _textSecondaryDark : _textSecondaryLight;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: surfaceColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: _primaryBlue,
        secondary: const Color(0xFF64B5F6),
        surface: cardColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 72,
          fontWeight: FontWeight.w300,
          color: textPrimary,
          letterSpacing: -2,
        ),
        headlineLarge: GoogleFonts.dmSans(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: textPrimary),
        bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: textSecondary),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.8,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.dmSans(color: textSecondary),
        prefixIconColor: textSecondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }
}
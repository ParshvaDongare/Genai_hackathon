import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF7C3AED);       // Violet-600
  static const Color primaryLight = Color(0xFF9F67FF);   // Lighter violet
  static const Color primaryDark = Color(0xFF5B21B6);    // Deep violet
  static const Color secondary = Color(0xFF10B981);      // Emerald-500
  static const Color secondaryLight = Color(0xFF34D399);  // Light emerald
  static const Color accent = Color(0xFFF59E0B);         // Amber
  static const Color accentOrange = Color(0xFFFF6B35);   // Orange accent
  static const Color error = Color(0xFFEF4444);          // Red
  static const Color warning = Color(0xFFF59E0B);        // Amber
  static const Color info = Color(0xFF3B82F6);           // Blue

  // Background Colors
  static const Color bgDark = Color(0xFF0A0A1B);         // Deepest dark
  static const Color bgCard = Color(0xFF13132A);         // Card bg
  static const Color bgSurface = Color(0xFF1A1A35);      // Surface
  static const Color bgElevated = Color(0xFF21213E);     // Elevated surface

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8D0);
  static const Color textMuted = Color(0xFF6B6B8E);
  static const Color textHint = Color(0xFF4A4A6A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F1F45), Color(0xFF13132A)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient walletGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF3B82F6), Color(0xFF10B981)],
    stops: [0.0, 0.5, 1.0],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: bgCard,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500, color: textSecondary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500, color: textMuted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: textHint, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}

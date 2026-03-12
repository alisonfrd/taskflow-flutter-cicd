import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cyber_colors.dart';

abstract class CyberTheme {
  // ──────────────────────────── DARK ────────────────────────────
  static ThemeData get dark {
    const primary = CyberColors.neonCyan;
    const secondary = CyberColors.neonPink;
    const bg = CyberColors.darkBg;
    const surface = CyberColors.darkSurface;
    const onSurface = CyberColors.darkText;

    final base = ThemeData.dark(useMaterial3: true);
    final cs = ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      tertiary: CyberColors.neonPurple,
      surface: surface,
      onSurface: onSurface,
      onPrimary: bg,
      onSecondary: bg,
      error: const Color(0xFFFF3A3A),
      outline: CyberColors.darkCardBorder,
    );

    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.orbitron(
          color: primary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: primary),
      ),
      textTheme: _textTheme(onSurface, CyberColors.darkTextSecondary),
      cardTheme: CardThemeData(
        color: CyberColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: CyberColors.darkCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: bg,
        elevation: 8,
        extendedTextStyle: GoogleFonts.orbitron(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      inputDecorationTheme: _inputTheme(primary, surface, onSurface),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primary.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(bg),
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CyberColors.darkCard,
        contentTextStyle: GoogleFonts.rajdhani(
          color: onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: secondary.withValues(alpha: 0.4), width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: CyberColors.darkDivider,
        space: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: bg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.orbitron(
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            fontSize: 13,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          textStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────── LIGHT ───────────────────────────
  static ThemeData get light {
    const primary = CyberColors.lightPrimary;
    const secondary = CyberColors.lightSecondary;
    const bg = CyberColors.lightBg;
    const surface = CyberColors.lightSurface;
    const onSurface = CyberColors.lightText;

    final base = ThemeData.light(useMaterial3: true);
    final cs = ColorScheme.light(
      primary: primary,
      secondary: secondary,
      tertiary: const Color(0xFF0066CC),
      surface: surface,
      onSurface: onSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      error: const Color(0xFFCC0000),
      outline: CyberColors.lightCardBorder,
    );

    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.orbitron(
          color: primary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: primary),
      ),
      textTheme: _textTheme(onSurface, CyberColors.lightTextSecondary),
      cardTheme: CardThemeData(
        color: CyberColors.lightCard,
        elevation: 2,
        shadowColor: primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: CyberColors.lightCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 8,
        extendedTextStyle: GoogleFonts.orbitron(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      inputDecorationTheme: _inputTheme(primary, surface, onSurface),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 4,
        shadowColor: primary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primary.withValues(alpha: 0.3), width: 1.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: BorderSide(color: primary.withValues(alpha: 0.6), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: GoogleFonts.rajdhani(
          color: onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: secondary.withValues(alpha: 0.3), width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: CyberColors.lightDivider,
        space: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.orbitron(
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            fontSize: 13,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          textStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // ──────────────────────── SHARED HELPERS ──────────────────────
  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: GoogleFonts.orbitron(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      color: primary,
      letterSpacing: 2,
    ),
    displayMedium: GoogleFonts.orbitron(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: 1.5,
    ),
    headlineLarge: GoogleFonts.orbitron(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: 1.5,
    ),
    headlineMedium: GoogleFonts.orbitron(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: primary,
      letterSpacing: 1,
    ),
    titleLarge: GoogleFonts.rajdhani(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: 0.5,
    ),
    titleMedium: GoogleFonts.rajdhani(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    bodyLarge: GoogleFonts.rajdhani(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: primary,
    ),
    bodyMedium: GoogleFonts.rajdhani(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: primary,
    ),
    bodySmall: GoogleFonts.rajdhani(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: secondary,
    ),
    labelLarge: GoogleFonts.orbitron(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: 1,
    ),
    labelSmall: GoogleFonts.rajdhani(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: secondary,
      letterSpacing: 0.5,
    ),
  );

  static InputDecorationTheme _inputTheme(
    Color primary,
    Color surface,
    Color onSurface,
  ) => InputDecorationTheme(
    filled: true,
    fillColor: surface,
    hintStyle: GoogleFonts.rajdhani(
      color: onSurface.withValues(alpha: 0.4),
      fontSize: 15,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: primary.withValues(alpha: 0.3), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFFF3A3A), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFFF3A3A), width: 2),
    ),
  );
}

import 'package:flutter/material.dart';

/// Paleta de cores cyberpunk para os temas dark e light.
abstract class CyberColors {
  // ──────────────────────────── NEON ────────────────────────────
  static const neonCyan = Color(0xFF00F5FF);
  static const neonPink = Color(0xFFFF006E);
  static const neonPurple = Color(0xFF9B4DFF);
  static const neonGreen = Color(0xFF00FF88);
  static const neonOrange = Color(0xFFFF6B00);

  // ─────────────────────────── DARK BG ──────────────────────────
  static const darkBg = Color(0xFF070714);
  static const darkSurface = Color(0xFF0F0F28);
  static const darkCard = Color(0xFF14142E);
  static const darkCardBorder = Color(0xFF252550);
  static const darkText = Color(0xFFDDDDFF);
  static const darkTextSecondary = Color(0xFF8888BB);
  static const darkDivider = Color(0xFF1E1E45);

  // ────────────────────────── LIGHT BG ──────────────────────────
  static const lightBg = Color(0xFFEEEBFF);
  static const lightSurface = Color(0xFFFAF9FF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardBorder = Color(0xFFD0C5F5);
  static const lightText = Color(0xFF1A0040);
  static const lightTextSecondary = Color(0xFF6644AA);
  static const lightDivider = Color(0xFFE0D8FF);

  // ─────────────────── LIGHT THEME – versão saturada ────────────
  static const lightPrimary = Color(0xFF6E00FF);
  static const lightSecondary = Color(0xFFCC0066);
  static const lightAccent = Color(0xFF0088FF);

  // ──────────────────── GRADIENTS HELPERS ───────────────────────
  static const darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBg, Color(0xFF0D0D2E)],
  );

  static const lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightBg, Color(0xFFE5DEFF)],
  );

  // ──────────────── NEON GLOW SHADOW HELPERS ────────────────────
  static List<BoxShadow> neonGlow(Color color, {double spread = 6}) => [
    BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: spread * 2),
    BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: spread * 4),
  ];

  static List<BoxShadow> subtleGlow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.25),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];
}

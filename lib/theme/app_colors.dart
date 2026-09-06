import 'package:flutter/material.dart';

// ─── Brand ────────────────────────────────────────────────────────────────────
const kPink      = Color(0xFFE91E8C);
const kPinkLight = Color(0xFFFCE4F3);
const kPinkPale  = Color(0xFFFFF0F9);
const kGrey      = Color(0xFF9E9E9E);
const kDark      = Color(0xFF1A1A2E);

// ─── Expanded tokens ──────────────────────────────────────────────────────────
class AppColors {
  // Pink scale
  static const pink500 = kPink;
  static const pink400 = Color(0xFFFF6BB5);
  static const pink300 = Color(0xFFFF9ECF);
  static const pink100 = Color(0xFFFCE4F3);
  static const pink50  = Color(0xFFFFF0F9);

  // Surfaces
  static const surface      = Color(0xFFF8F7FB);
  static const surfaceCard  = Colors.white;
  static const surfaceMuted = Color(0xFFF3F0F7);
  static const outline      = Color(0xFFE9E0F0);
  static const outlineSoft  = Color(0xFFF0E6F5);

  // Text
  static const textPrimary   = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B6B7B);
  static const textTertiary  = Color(0xFF9E9EAE);

  // Dark mode
  static const darkBg     = Color(0xFF0F0F1A);
  static const darkSurface= Color(0xFF1E1E2F);
  static const darkCard   = Color(0xFF2A2A40);

  // Gradients
  static const gradientPink = LinearGradient(
    colors: [kPink, Color(0xFFFF6BB5)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradientPinkWarm = LinearGradient(
    colors: [Color(0xFFFF6BB5), kPink, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradientDark = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF2D1B4E), Color(0xFF3D1060)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradientCardPink = LinearGradient(
    colors: [Color(0xFFFCE4F3), Color(0xFFFFF0F9)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradientViolet = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  // Shadows — centralized
  static List<BoxShadow> shadowSoft = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
    BoxShadow(color: kPink.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
  ];
  static List<BoxShadow> shadowCard = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
    BoxShadow(color: kPink.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> shadowPink = [
    BoxShadow(color: kPink.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
  ];
}

// Backwards compat aliases
const kPinkGradient = AppColors.gradientPink;

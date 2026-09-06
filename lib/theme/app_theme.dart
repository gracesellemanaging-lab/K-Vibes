import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: kPink, brightness: Brightness.light, surface: AppColors.surface);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: kPink,
        side: BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: kPinkLight,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kPink);
          return const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kGrey);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const IconThemeData(color: kPink);
          return const IconThemeData(color: kGrey);
        }),
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        showDragHandle: true,
        dragHandleColor: Colors.grey.shade300,
        dragHandleSize: Size(40, 4),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
        activeTrackColor: kPink,
        inactiveTrackColor: AppColors.outlineSoft,
        thumbColor: kPink,
        overlayColor: kPink.withValues(alpha: 0.15),
      ),
      dividerTheme: DividerThemeData(color: AppColors.outlineSoft, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(seedColor: kPink, brightness: Brightness.dark, surface: AppColors.darkBg);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: kPink.withValues(alpha: 0.25),
        height: 72,
      ),
    );
  }
}

// Radius tokens
class AppRadius {
  static const xs = Radius.circular(10);
  static const sm = Radius.circular(14);
  static const md = Radius.circular(20);
  static const lg = Radius.circular(28);
  static const xl = Radius.circular(32);
  static BorderRadius r10 = BorderRadius.circular(10);
  static BorderRadius r14 = BorderRadius.circular(14);
  static BorderRadius r16 = BorderRadius.circular(16);
  static BorderRadius r20 = BorderRadius.circular(20);
  static BorderRadius r24 = BorderRadius.circular(24);
  static BorderRadius r28 = BorderRadius.circular(28);
}

// Spacing
class AppSpacing {
  static const double xxs = 4;
  static const double xs  = 8;
  static const double sm  = 12;
  static const double md  = 16;
  static const double lg  = 20;
  static const double xl  = 24;
  static const double xxl = 32;
}

// Durations
class AppMotion {
  static const fast   = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 300);
  static const slow   = Duration(milliseconds: 500);
  static const curve  = Curves.easeInOutCubicEmphasized;
}

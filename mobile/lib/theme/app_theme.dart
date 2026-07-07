import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color seedColor = Color(0xFF7C5CFC);

  static const Curve premiumCurve = Cubic(0.32, 0.72, 0, 1);
  static const Curve springCurve = Cubic(0.34, 1.56, 0.64, 1);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      surface: const Color(0xFFF8F9FC),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF8F9FC),
      textTheme: _textTheme,
      brightness: Brightness.light,
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF050505),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF050505),
      textTheme: _textTheme,
      brightness: Brightness.dark,
    );
  }

  static TextTheme get _textTheme {
    return GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          height: 1.15,
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.55,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  static BoxDecoration doubleBezel({
    required ColorScheme colorScheme,
    required bool isDark,
    double outerRadius = 28,
    double innerRadius = 25,
    Color? outerBorderColor,
    Color? innerColor,
    List<Color>? outerGradient,
    List<Color>? innerGradient,
    List<BoxShadow>? outerShadow,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(outerRadius),
      gradient: outerGradient != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: outerGradient,
            )
          : null,
      color: outerGradient != null ? null : Colors.transparent,
      border: Border.all(
        color: outerBorderColor ??
            (isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04)),
        width: 1,
      ),
      boxShadow: outerShadow,
    );
  }

  static BoxDecoration doubleBezelInner({
    required ColorScheme colorScheme,
    required bool isDark,
    double radius = 25,
    Color? color,
    List<Color>? gradient,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: color ??
          (isDark
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : Colors.white),
      gradient: gradient != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

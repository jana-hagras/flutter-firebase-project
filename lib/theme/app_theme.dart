import 'package:flutter/material.dart';

class AccentColor {
  final String name;
  final Color color;
  const AccentColor(this.name, this.color);
}

class AppTheme {
  static const List<AccentColor> accentColors = [
    AccentColor("Cyan", Color(0xFF00C2FF)),
    AccentColor("Indigo", Color(0xFF6366F1)),
    AccentColor("Emerald", Color(0xFF10B981)),
    AccentColor("Rose", Color(0xFFF43F5E)),
    AccentColor("Coral", Color(0xFFFF6B6B)),
    AccentColor("Gold", Color(0xFFF59E0B)),
    AccentColor("Mint", Color(0xFF2DD4BF)),
    AccentColor("Peach", Color(0xFFFB923C)),
    AccentColor("Lavender", Color(0xFFA78BFA)),
    AccentColor("Sky", Color(0xFF38BDF8)),
  ];

  // ── Dark Theme Colors ──
  static const Color bgDark = Color(0xFF0B0E14);
  static const Color surfaceDark = Color(0xFF131720);
  static const Color cardDark = Color(0xFF1A1F2E);
  static const Color cardDarkAlt = Color(0xFF212738);
  static const Color textDark = Color(0xFFE2E8F0);
  static const Color textDarkSub = Color(0xFF94A3B8);

  // ── Light Theme Colors ──
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardLightAlt = Color(0xFFF1F5F9);
  static const Color textLight = Color(0xFF0F172A);
  static const Color textLightSub = Color(0xFF64748B);

  static ThemeData buildTheme({
    required bool isDark,
    required Color accent,
  }) {
    final bg = isDark ? bgDark : bgLight;
    final surface = isDark ? surfaceDark : surfaceLight;
    final card = isDark ? cardDark : cardLight;
    final text = isDark ? textDark : textLight;
    final textSub = isDark ? textDarkSub : textLightSub;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      primaryColor: accent,
      cardColor: card,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        onPrimary: contrastColor(accent),
        secondary: accent.withValues(alpha: 0.8),
        onSecondary: contrastColor(accent),
        error: const Color(0xFFEF4444),
        onError: Colors.white,
        surface: surface,
        onSurface: text,
        surfaceContainerHighest: card,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: accent),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF0F1318) : Colors.white,
        selectedItemColor: accent,
        unselectedItemColor: textSub,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
            color: text, fontWeight: FontWeight.bold, fontSize: 28),
        headlineMedium: TextStyle(
            color: text, fontWeight: FontWeight.bold, fontSize: 22),
        titleLarge: TextStyle(
            color: text, fontWeight: FontWeight.bold, fontSize: 18),
        titleMedium: TextStyle(
            color: text, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: text, fontSize: 16),
        bodyMedium: TextStyle(color: textSub, fontSize: 14),
        bodySmall: TextStyle(color: textSub, fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? cardDarkAlt : cardLightAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        labelStyle: TextStyle(color: textSub),
        hintStyle: TextStyle(color: textSub.withValues(alpha: 0.6)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: contrastColor(accent),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          elevation: 0,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: contrastColor(accent),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? cardDarkAlt : cardLightAlt,
        selectedColor: accent.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: textSub, fontSize: 13),
        secondaryLabelStyle: TextStyle(color: accent, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? cardDark : cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? cardDark : const Color(0xFF1E293B),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        thickness: 1,
      ),
    );
  }

  static Color contrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF0F172A) : Colors.white;
  }

  // Glow box shadow for accent-colored elements
  static List<BoxShadow> glowShadow(Color accent, {double blur = 20, double spread = 0, double opacity = 0.3}) {
    return [
      BoxShadow(
        color: accent.withValues(alpha: opacity),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }

  // Neon border decoration
  static BoxDecoration neonCard({
    required bool isDark,
    Color? accent,
    double radius = 20,
  }) {
    final card = isDark ? cardDark : cardLight;
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(radius),
      border: accent != null
          ? Border.all(color: accent.withValues(alpha: 0.2), width: 1.5)
          : null,
      boxShadow: isDark
          ? [
              BoxShadow(
                color: (accent ?? Colors.white).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
    );
  }

  // Glassmorphism decoration
  static BoxDecoration glassDecoration({
    required bool isDark,
    Color? accent,
    double blur = 12,
    double opacity = 0.1,
    double radius = 24,
  }) {
    return BoxDecoration(
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: (accent ?? Colors.white).withValues(alpha: 0.15),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

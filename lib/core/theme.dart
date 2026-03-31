// lib/core/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D96FF);
  static const Color accent = Color(0xFFF7971E);
  static const Color accentLight = Color(0xFFFFBD59);
  static const Color success = Color(0xFF00D8A4);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFD93D);

  // Dark theme colors
  static const Color darkBg = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF161627);
  static const Color darkCard = Color(0xFF1E1E35);
  static const Color darkCardAlt = Color(0xFF252540);
  static const Color darkText = Color(0xFFE8E8FF);
  static const Color darkTextSub = Color(0xFF9898B8);
  static const Color darkBorder = Color(0xFF2A2A45);

  // Light theme colors
  static const Color lightBg = Color(0xFFF5F5FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F0FF);
  static const Color lightText = Color(0xFF1A1A3A);
  static const Color lightTextSub = Color(0xFF6060A0);
  static const Color lightBorder = Color(0xFFE0E0F5);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: darkSurface,
      error: error,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
        .apply(bodyColor: darkText, displayColor: darkText),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: darkText,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: darkText),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: darkBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: darkTextSub),
      hintStyle: const TextStyle(color: darkTextSub),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 8,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return darkTextSub;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary.withValues(alpha: 0.7);
        }
        return darkCardAlt;
      }),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: lightSurface,
      error: error,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme)
        .apply(bodyColor: lightText, displayColor: lightText),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: lightText,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: lightText),
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: lightBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: lightTextSub),
      hintStyle: const TextStyle(color: lightTextSub),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return lightTextSub;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary.withValues(alpha: 0.7);
        }
        return lightCard;
      }),
    ),
  );
}

class AppConstants {
  static const String appName = 'BillBuddiesX';
  static const String appVersion = '1.0.0';
  static const String devEmail = 'Adnanmirza.console1@gmail.com';
  static const String devName = 'DanaTypeApps';

  static const List<String> currencies = [
    'USD \$', 'EUR €', 'GBP £', 'PKR ₨', 'INR ₹',
    'AED د.إ', 'SAR ﷼', 'JPY ¥', 'CNY ¥', 'CAD CA\$',
    'AUD A\$', 'CHF Fr', 'KWD KD', 'BDT ৳', 'TRY ₺',
  ];

  static const Map<String, String> currencySymbols = {
    'USD \$': '\$', 'EUR €': '€', 'GBP £': '£', 'PKR ₨': '₨',
    'INR ₹': '₹', 'AED د.إ': 'د.إ', 'SAR ﷼': '﷼', 'JPY ¥': '¥',
    'CNY ¥': '¥', 'CAD CA\$': 'CA\$', 'AUD A\$': 'A\$', 'CHF Fr': 'Fr',
    'KWD KD': 'KD', 'BDT ৳': '৳', 'TRY ₺': '₺',
  };

  static String getCurrencySymbol(String currency) {
    return currencySymbols[currency] ?? '\$';
  }
}
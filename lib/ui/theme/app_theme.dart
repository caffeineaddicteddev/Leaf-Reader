import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  const AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF1A1A2E),
      surface: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF2C2C2A),
      secondary: const Color(0xFF4A7B5E),
      surfaceContainerLow: const Color(0xFFF2F3FA),
      surfaceContainer: const Color(0xFFFFFFFF),
      surfaceContainerHigh: const Color(0xFFE5E8F0),
      surfaceContainerHighest: const Color(0xFFDEE2EC),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F7F4),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Color(0xFFF8F7F4),
      foregroundColor: Color(0xFF2C2C2A),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: Color(0xFFFFFFFF),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFFE8E6D9), // Warm white for premium feel
      onPrimary: const Color(0xFF18181B),
      secondary: const Color(0xFF6AAF88), // Sage green accent
      onSecondary: const Color(0xFF18181B),
      surface: const Color(0xFF18181B), // Zinc-900
      onSurface: const Color(0xFFE8E6D9),
      surfaceContainerLow: const Color(0xFF111113), // Slightly lighter than background
      surfaceContainer: const Color(0xFF18181B), // Standard surface
      surfaceContainerHigh: const Color(0xFF27272A), // Zinc-800
      surfaceContainerHighest: const Color(0xFF3F3F46), // Zinc-700
      outline: const Color(0xFF3F3F46),
      outlineVariant: const Color(0xFF27272A),
    ),
    scaffoldBackgroundColor: const Color(0xFF09090B), // Zinc-950 (Slate-like but cleaner)
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Color(0xFF09090B),
      foregroundColor: Color(0xFFE8E6D9),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: Color(0xFF111113), // Match surfaceContainerLow
      selectedItemColor: Color(0xFFE8E6D9),
      unselectedItemColor: Color(0x66E8E6D9),
    ),
  );
}

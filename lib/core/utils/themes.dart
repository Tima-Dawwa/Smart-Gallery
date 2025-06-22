import 'package:flutter/material.dart';

class Themes {
  // Modern gallery app color scheme
  static Color primary = const Color(
    0xFF2C3E50,
  ); // Deep blue-grey for sophistication
  static Color? secondary = const Color(0xFFF8F9FA); // Clean white background
  static Color third = const Color(0xFF3498DB); // Bright blue for accents
  static Color accent = const Color(0xFF9B59B6); // Purple for highlights
  static Color success = const Color(0xFF27AE60); // Green for success states
  static Color warning = const Color(0xFFE67E22); // Orange for warnings
  static Color error = const Color(0xFFE74C3C); // Red for errors
  static Color dark = const Color(0xFF1A1A1A); // Dark background option
  static Color light = const Color(0xFFECF0F1); // Light grey for cards

  // Gradient colors for modern gallery feel
  static LinearGradient primaryGradient = LinearGradient(
    colors: [const Color(0xFF2C3E50), const Color(0xFF3498DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient = LinearGradient(
    colors: [const Color(0xFF9B59B6), const Color(0xFF3498DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData timePickerTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.light(
      primary: Themes.primary,
      secondary: Themes.third,
      onSurface: Themes.primary,
      surface: Themes.secondary!,
    ),
    buttonTheme: ButtonThemeData(
      colorScheme: ColorScheme.light(
        primary: Themes.third,
        secondary: Themes.accent,
      ),
    ),
  );

  static ThemeData datePickerTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.light(
      primary: Themes.primary,
      secondary: Themes.third,
      onSurface: Themes.primary,
      surface: Themes.secondary!,
    ),
    buttonTheme: ButtonThemeData(
      colorScheme: ColorScheme.light(
        primary: Themes.primary,
        secondary: Themes.third,
      ),
    ),
  );

  // Main app theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: Themes.primary,
    secondaryHeaderColor: Themes.third,
    scaffoldBackgroundColor: Themes.secondary,
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Themes.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Themes.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Themes.third),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Themes.accent,
      foregroundColor: Colors.white,
    ), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(0xFF2C3E50, {
      50: const Color(0xFFE8EAF0),
      100: const Color(0xFFC5CADA),
      200: const Color(0xFF9EA7C1),
      300: const Color(0xFF7784A8),
      400: const Color(0xFF5A6A95),
      500: const Color(0xFF2C3E50),
      600: const Color(0xFF273849),
      700: const Color(0xFF212F40),
      800: const Color(0xFF1B2737),
      900: const Color(0xFF101927),
    })).copyWith(background: Themes.secondary),
  );

  // Dark theme for gallery app
 static ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: Themes.third,
  secondaryHeaderColor: Themes.accent,
  scaffoldBackgroundColor: Themes.dark,
  cardColor: const Color(0xFF2C2C2C),
  appBarTheme: AppBarTheme(
    backgroundColor: Themes.dark,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Themes.third,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Themes.third),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Themes.accent,
    foregroundColor: Colors.white,
  ),
  colorScheme: ColorScheme.dark().copyWith(
    background: Themes.dark,
    primary: Themes.third,
    secondary: Themes.accent,
  ),
);
}

// Smart Gallery specific color palette
class GalleryColors {
  // Photo grid colors
  static Color photoBackground = const Color(0xFFF5F5F5);
  static Color photoSelected = const Color(0xFF3498DB);
  static Color photoHover = const Color(0xFFE8F4FD);

  // Album colors
  static Color albumBackground = const Color(0xFFFFFFFF);
  static Color albumShadow = const Color(0xFF000000).withOpacity(0.1);

  // Category colors
  static List<Color> categoryColors = [
    const Color(0xFF3498DB), // Blue
    const Color(0xFF9B59B6), // Purple
    const Color(0xFF27AE60), // Green
    const Color(0xFFE67E22), // Orange
    const Color(0xFFE74C3C), // Red
    const Color(0xFF1ABC9C), // Turquoise
    const Color(0xFFF39C12), // Yellow
    const Color(0xFF34495E), // Dark blue
  ];

  // Status colors
  static Color uploading = const Color(0xFF3498DB);
  static Color uploaded = const Color(0xFF27AE60);
  static Color failed = const Color(0xFFE74C3C);
  static Color processing = const Color(0xFFF39C12);
}

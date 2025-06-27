import 'package:flutter/material.dart';

class Themes {
  // Your custom color palette
  static Color lightPurple = const Color(0xFFAC8FF1); // RGB(172, 143, 241)
  static Color lightBlue = const Color(0xFF66D4DE); // RGB(102, 212, 222)
  static Color darkPurple = const Color(0xFF7D78F5); // RGB(125, 120, 245)
  static Color customBlack = const Color(0xFF000000); // RGB(0, 0, 0)
  static Color customWhite = const Color(0xFFFFFFFF); // RGB(255, 255, 255)

  // Modern gallery app color scheme (updated with your colors)
  static Color primary = lightPurple; // Using your light purple as primary
  static Color? secondary = customWhite; // Using your white as secondary
  static Color third = lightBlue; // Using your light blue for accents
  static Color accent = darkPurple; // Using your dark purple for highlights
  static Color success = const Color(0xFF27AE60); // Green for success states
  static Color warning = const Color(0xFFE67E22); // Orange for warnings
  static Color error = const Color(0xFFE74C3C); // Red for errors
  static Color dark = const Color(0xFF1A1A1A); // Dark background option
  static Color light = const Color(0xFFECF0F1); // Light grey for cards

  // Custom gradient using your three colors
  static LinearGradient customGradient = LinearGradient(
    colors: [lightPurple, lightBlue, darkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: const [0.0, 0.5, 1.0],
  );

  // Alternative gradients with different combinations
  static LinearGradient primaryGradient = LinearGradient(
    colors: [lightPurple, darkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient = LinearGradient(
    colors: [lightBlue, darkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Three-color circular gradient
  static RadialGradient customRadialGradient = RadialGradient(
    colors: [lightPurple, lightBlue, darkPurple],
    stops: const [0.0, 0.5, 1.0],
    center: Alignment.center,
  );

  


}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Light Theme Palette - "Saffron Sunrise"
  
  // Primary: Traditional Saffron/Orange
  static const Color primaryOrange = Color(0xFFFF7A00); // Vibrant Saffron
  static const Color primaryDeep = Color(0xFFE65100);   // Deep Orange
  static const Color primaryLight = Color(0xFFFFE0B2);  // Soft Peach
  
  // Accent: Premium Gold
  static const Color accentGold = Color(0xFFFFB300);    // Warm Gold
  static const Color accentGoldDark = Color(0xFFFF8F00); 
  static const Color accentGoldLight = Color(0xFFFFF8E1); 
  
  // Secondary: Elegant Maroon for depth
  static const Color mysticalPurple = Color(0xFF8D1B3D); // Deep Maroon
  static const Color mysticalLight = Color(0xFFFCE4EC);  // Soft Pink

  // Neutrals: Warm & Clean
  static const Color neutralDark = Color(0xFF2D2D2D);   // Rich Charcoal (Text)
  static const Color neutralGrey = Color(0xFF757575);   // Medium Grey
  static const Color neutralMedium = Color(0xFFBDBDBD); // Soft Grey
  static const Color neutralLight = Color(0xFFFAFAFA);  // Off-White (Background)
  static const Color white = Color(0xFFFFFFFF);
  
  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);  // Pure White for cards
  static const Color cosmicVoid = Color(0xFF1A1A2E);    // Legacy (for dark mode if ever needed)

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningAmber = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFE53935);
  static const Color infoBlue = Color(0xFF2196F3);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF9933), Color(0xFFFF7A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [accentGold, accentGoldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [neutralLight, Color(0xFFF5F5F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Legacy mappings
  static const LinearGradient deepSpaceGradient = cosmicGradient;
  static const Color yellowPrimary = primaryOrange;
  static const Color creamPrimary = primaryLight;
  static const Color goldAccent = accentGold;
  static const Color textDark = neutralDark;
  static const Color textLight = neutralMedium;
  static const Color neutralSoft = neutralLight;
  static Color get shadowColor => Colors.black.withOpacity(0.08);
  static const Color celestialVoid = cosmicVoid;

  // Shadows - Soft & Elegant
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => cardShadow;

  static List<BoxShadow> get glowShadow => [
     BoxShadow(
      color: primaryOrange.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];
  
  static List<BoxShadow> get purpleGlow => [
     BoxShadow(
      color: mysticalPurple.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  // Legacy/Migration Helpers
  static List<BoxShadow> get goldGlowShadow => [
     BoxShadow(
      color: accentGold.withOpacity(0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  static Color get celestialPurple => mysticalPurple;
  static Color get celestialBlue => infoBlue;
  static Color get primarySoft => primaryLight;
  static Color get saffronPrimary => primaryOrange;
  static const Color yellowLight = accentGoldLight;


  // Glassmorphism - Light & Airy
  static BoxDecoration get glassMorphism => BoxDecoration(
    color: white.withOpacity(0.9),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.grey.withOpacity(0.1),
      width: 1.0,
    ),
    boxShadow: softShadow,
  );

  // Theme Data - LIGHT THEME
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light, // LIGHT MODE
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: neutralLight,
      colorScheme: ColorScheme.light(
        primary: primaryOrange,
        secondary: mysticalPurple,
        tertiary: accentGold,
        surface: white,
        onPrimary: white,
        onSecondary: white,
        onSurface: neutralDark,
        outline: neutralMedium.withOpacity(0.5),
        error: errorRed,
      ),
      fontFamily: GoogleFonts.outfit().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          color: neutralDark,
          fontWeight: FontWeight.bold,
          fontSize: 32,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: neutralDark,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          color: neutralDark,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        titleMedium: GoogleFonts.outfit(
          color: neutralDark,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: neutralDark,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: neutralGrey,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.outfit(
          color: neutralGrey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: neutralDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: neutralDark,
        ),
        iconTheme: const IconThemeData(color: neutralDark),
      ),
      
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), 
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: white,
          elevation: 4,
          shadowColor: primaryOrange.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF5F5F5), // Light Grey Input
        contentPadding: const EdgeInsets.all(18),
        hintStyle: GoogleFonts.outfit(color: neutralGrey, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
      ),
    );
  }

  // Dark Theme (Placeholder, but not used)
  static ThemeData get darkTheme => lightTheme;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Enhanced Professional Color Palette
  // Celestial Glassmorphism Color Palette
  
  // Light Mode (Solar/Day)
  // Cosmic AI Theme Palette
  
  // Primary Colors (Deep Space & Nebula)
  static const Color primaryOrange = Color(0xFF8B5CF6); // Changed to Electric Purple
  static const Color primaryDeep = Color(0xFF6D28D9);   // Deep Purple
  static const Color celestialVoid = Color(0xFF0B0B19); // Deepest Space Background
  static const Color celestialBlue = Color(0xFF1E1E2E); // Card Background
  static const Color celestialPurple = Color(0xFF581C87); // Restored for compatibility
  static const Color primaryLight = Color(0xFFFFF0EB);  // Restored for compatibility
  
  // Accents
  static const Color accentGold = Color(0xFFFFD700);    // Celestial Gold
  static const Color accentGoldLight = Color(0xFFFFE57F);
  
  // Neutrals
  static const Color neutralDark = Color(0xFF0F172A); 
  static const Color neutralMedium = Color(0xFF94A3B8);
  static const Color neutralLight = Color(0xFFCBD5E1);
  static const Color neutralSoft = Color(0xFFF1F5F9);
  static const Color white = Color(0xFFFFFFFF);
  
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color warningAmber = Color(0xFFF59E0B);
  
  // Legacy colors for compatibility
  static const Color primarySoft = Color(0xFFF3E8FF); // Soft Violet for Cosmic Theme
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [accentGold, Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [celestialBlue, celestialPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient deepSpaceGradient = LinearGradient(
    colors: [celestialVoid, celestialBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Glass Shadows & Effects
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: celestialBlue.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryOrange.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> get cosmicGlow => [
    BoxShadow(
      color: celestialPurple.withOpacity(0.4),
      blurRadius: 25,
      offset: const Offset(0, 4),
      spreadRadius: -5,
    ),
  ];

  // Compatibility Shadows
  static List<BoxShadow> get mediumShadow => softShadow;
  
  static List<BoxShadow> get goldGlowShadow => [
    BoxShadow(
      color: accentGold.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -2,
    ),
  ];
  
  static BoxDecoration get glassMorphism => BoxDecoration(
    color: white.withOpacity(0.7),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: white.withOpacity(0.4),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: celestialBlue.withOpacity(0.08),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  static BoxDecoration get glassMorphismDark => BoxDecoration(
    color: celestialBlue.withOpacity(0.6),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: white.withOpacity(0.1),
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static Border get softBorder => Border.all(
    color: neutralLight.withOpacity(0.3),
    width: 1,
  );
  
  // Legacy colors for compatibility
  static const Color yellowPrimary = primaryOrange;
  static const Color yellowDark = primaryDeep;
  static const Color yellowLight = primaryLight;
  static const Color textDark = neutralDark;
  static const Color textLight = neutralMedium;
  static const Color goldAccent = accentGold;
  static const Color saffronPrimary = primaryOrange;
  static const Color saffronDark = primaryDeep;
  static const Color creamPrimary = primarySoft;


  static const Duration staggeredAnimationDuration = Duration(milliseconds: 375);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnBackground = Color(0xFFE0E0E0);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkPrimary = Color(0xFFFF6B35);
  static const Color darkSecondary = Color(0xFFFFB800);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        primary: primaryOrange,
        secondary: accentGold,
        surface: white,
        background: neutralSoft,
        error: errorRed,
        onPrimary: white,
        onSecondary: neutralDark,
        onSurface: neutralDark,
        onBackground: neutralDark,
        onError: white,
      ),
      scaffoldBackgroundColor: neutralSoft,
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: neutralDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit( // Updated font
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: neutralDark,
        ),
        shadowColor: celestialBlue.withOpacity(0.05),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shadowColor: celestialBlue.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: white,
          elevation: 0,
          shadowColor: primaryOrange.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith( // Updated to Outfit
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: neutralDark,
        ),
        // ... mapped similarly for others
        bodyLarge: GoogleFonts.inter( // Keep body as Inter for readability
          fontSize: 16,
          color: neutralDark,
        ),
      ),
      // ... keep other inputs
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryOrange,
        secondary: celestialPurple,
        surface: celestialBlue, // Celestial Blue Surface
        background: celestialVoid, // Deep Space Background
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: white,
        onBackground: white,
      ),
      scaffoldBackgroundColor: celestialVoid,
      appBarTheme: AppBarTheme(
        backgroundColor: celestialBlue.withOpacity(0.8), // Glassy
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      cardTheme: CardThemeData(
        color: celestialBlue,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryOrange.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: white,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: white.withOpacity(0.9),
        ),
      ),
      // ...
    );
  }
}

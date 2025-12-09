import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Enhanced Professional Color Palette
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryDeep = Color(0xFFE55A2B);
  static const Color primaryLight = Color(0xFFFFF0EB); // Slightly warmer light
  static const Color primarySoft = Color(0xFFFFF8F6);
  
  static const Color accentGold = Color(0xFFFFB800);
  static const Color accentGoldLight = Color(0xFFFFF9E6);
  
  static const Color neutralDark = Color(0xFF1F2937); // Cool dark gray
  static const Color neutralMedium = Color(0xFF6B7280);
  static const Color neutralLight = Color(0xFFD1D5DB);
  static const Color neutralSoft = Color(0xFFF3F4F6);
  static const Color white = Color(0xFFFFFFFF);
  
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, primaryDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [accentGold, Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Modern Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: neutralDark.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: neutralDark.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];
  
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: neutralDark.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
  ];
  
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryOrange.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -2,
    ),
  ];
  
  static List<BoxShadow> get goldGlowShadow => [
    BoxShadow(
      color: accentGold.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];
  
  // Border styles
  static BoxBorder get softBorder => Border.all(
    color: neutralLight.withOpacity(0.3),
    width: 1,
  );
  
  static BoxBorder get mediumBorder => Border.all(
    color: neutralLight.withOpacity(0.5),
    width: 1.5,
  );
  
  static BoxBorder get accentBorder => Border.all(
    color: primaryOrange.withOpacity(0.3),
    width: 1.5,
  );
  
  // Glass Morphism Effects
  static BoxDecoration get glassMorphism => BoxDecoration(
    color: white.withOpacity(0.85),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: white.withOpacity(0.5),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: neutralDark.withOpacity(0.05),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  static BoxDecoration get glassMorphismDark => BoxDecoration(
    color: neutralDark.withOpacity(0.6),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: white.withOpacity(0.1),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  // Gradient Overlays
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF9FAFB),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient infoGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
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
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: neutralDark,
        ),
        shadowColor: neutralDark.withOpacity(0.1),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shadowColor: neutralDark.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: neutralDark,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: neutralDark,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: neutralDark,
          height: 1.3,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: neutralDark,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: neutralDark,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: neutralDark,
          height: 1.4,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: neutralDark,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: neutralDark,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: neutralDark,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: neutralMedium,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: neutralLight,
          height: 1.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: neutralLight.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: neutralLight.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed),
        ),
        hintStyle: GoogleFonts.inter(
          color: neutralLight,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryOrange,
        unselectedItemColor: neutralLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }


}

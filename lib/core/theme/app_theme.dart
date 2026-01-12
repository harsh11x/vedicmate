import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===========================================================================
  // PALETTE: DIVINE MINIMALISM
  // ===========================================================================
  
  // Primary: Void Black / Deepest Charcoal
  // Represents the cosmos, infinite potential, authority.
  static const Color divinePrimary = Color(0xFF121212); 
  
  // Secondary: Muted Gold
  // Represents wisdom, divinity, enlightenment. Used for CTAs and highlights.
  static const Color divineGold = Color(0xFFC39130); 
  static const Color divineGoldLight = Color(0xFFE5B965);

  // Backgrounds: Zen White & Soft Mist
  // Clean, distraction-free canvas.
  static const Color divineBackground = Color(0xFFFAFAFA); // Soft off-white
  static const Color divineSurface = Color(0xFFFFFFFF);    // Pure white for cards
  
  // Text Colors
  static const Color textBlack = Color(0xFF1A1A1A);       // High contrast content
  static const Color textGrey = Color(0xFF666666);        // Subtitles
  static const Color textLight = Color(0xFFAAAAAA);       // Placeholders

  // Status
  static const Color successGreen = Color(0xFF2E6F40);    // Kept from Forest theme
  static const Color errorRed = Color(0xFFD32F2F);
  
  // Legacy / Compatibility Mappings
  static const Color primaryOrange = divineGold; 
  static const Color mysticalPurple = divinePrimary;
  static const Color accentGold = divineGold;
  static const Color forestPrimary = divinePrimary;
  static const Color forestSecondary = divineGold;
  static const Color forestBackground = divineBackground;
  static const Color neutralLight = divineBackground;
  static const Color neutralDark = textBlack;
  static const Color neutralMedium = textGrey;
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color primaryLight = divineGoldLight;
  static Color get shadowColor => Colors.black.withOpacity(0.05);

  // Missing Legacy Constants
  static const Color yellowPrimary = divineGold;
  static const Color goldAccent = divineGold;
  static const Color creamPrimary = Color(0xFFFFFDD0);
  static const Color textDark = textBlack;
  static const Color white = Colors.white;
  static const Color saffronPrimary = Color(0xFFFF7A00); // Keep original saffron for legacy specific
  static const Color celestialBlue = Color(0xFF1A237E);
  static const Color celestialPurple = divinePrimary;
  static const Color deepSpaceGradient = divinePrimary; // Fallback
  static const Color cosmicGradient = divinePrimary; // Fallback
  static const Color warmGradient = divineGold; // Fallback
  
  static ThemeData get darkTheme => lightTheme; // For now fall back to light

  // More Legacy Mappings
  static const Gradient primaryGradient = LinearGradient(colors: [divinePrimary, divinePrimary]);
  static const Gradient goldGradient = LinearGradient(colors: [divineGold, divineGoldLight]);
  static const Color neutralSoft = Color(0xFFF5F5F5);
  static const Color warningAmber = Color(0xFFFFC107);
  static const Color primarySoft = divineGoldLight;
  static const Color neutralGrey = textGrey;
  static const Color celestialVoid = divinePrimary;
  static const Color forestDark = divinePrimary;
  
  static List<BoxShadow> get glowShadow => cardShadow;
  static List<BoxShadow> get mediumShadow => cardShadow;
  static List<BoxShadow> get goldGlowShadow => [
    BoxShadow(
      color: divineGold.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  static const Color yellowLight = divineGoldLight;
  static List<BoxShadow> get purpleGlow => cardShadow; // Fallback
  
  // ===========================================================================
  // TYPOGRAPHY
  // ===========================================================================
  // Headings: Playfair Display (Serif) - Elegant, Traditional, Editorial.
  static TextStyle get titleStyle => GoogleFonts.playfairDisplay(
    color: textBlack,
    fontWeight: FontWeight.w700,
  );

  // Body: Plus Jakarta Sans (Sans-Serif) - Modern, Geometric, Readable.
  static TextStyle get bodyStyle => GoogleFonts.plusJakartaSans(
    color: textBlack,
    fontWeight: FontWeight.normal,
  );

  // ===========================================================================
  // SHADOWS & GLASS
  // ===========================================================================
  
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static BoxDecoration get glassMorphism => BoxDecoration(
    color: divineSurface.withOpacity(0.95), // Less transparent, more solid/premium
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.black.withOpacity(0.03)),
    boxShadow: softShadow,
  );

  // ===========================================================================
  // THEME DATA
  // ===========================================================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: divinePrimary,
      scaffoldBackgroundColor: divineBackground,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: divinePrimary,
        secondary: divineGold,
        surface: divineSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textBlack,
        background: divineBackground,
        error: errorRed,
        outline: Colors.grey.withOpacity(0.2),
      ),

      // Typography System
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: TextTheme(
        displayLarge: titleStyle.copyWith(fontSize: 40, height: 1.1),
        displayMedium: titleStyle.copyWith(fontSize: 32, height: 1.2),
        displaySmall: titleStyle.copyWith(fontSize: 28, height: 1.2),
        
        headlineLarge: titleStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
        headlineMedium: titleStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
        
        titleLarge: bodyStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        titleMedium: bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        
        bodyLarge: bodyStyle.copyWith(fontSize: 16),
        bodyMedium: bodyStyle.copyWith(fontSize: 14, color: textGrey),
        bodySmall: bodyStyle.copyWith(fontSize: 12, color: textGrey),
      ),

      // Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: divineBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textBlack),
        titleTextStyle: titleStyle.copyWith(fontSize: 20),
      ),
      
      cardTheme: CardThemeData(
        color: divineSurface,
        elevation: 0, // Flat is cleaner
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide.none, // No borders, just soft shadow or pure flat
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: divinePrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: bodyStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: divinePrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          side: const BorderSide(color: divinePrimary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: bodyStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: divineSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        hintStyle: bodyStyle.copyWith(color: textLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: divinePrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
      ),
    );
  }
}

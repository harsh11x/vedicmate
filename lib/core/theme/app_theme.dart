import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===========================================================================
  // PALETTE: DIVINE MINIMALISM
  // ===========================================================================
  
  // Primary: Void Black / Deepest Charcoal
  // Represents the cosmos, infinite potential, authority.
  // Primary: Ink Black / Deep Charcoal
  // Represents hand-drawn pen ink.
  static const Color divinePrimary = Color(0xFF2D2D2D); 
  
  // Secondary: Warm Ochre / Saffron
  // Represents traditional spiritual colors.
  static const Color divineGold = Color(0xFFE67E22); 
  static const Color divineGoldLight = Color(0xFFF39C12);

  // Backgrounds: Warm Parchment & Light Ivory
  // Organic, paper-like feel.
  static const Color divineBackground = Color(0xFFFFF9E6); // Warm parchment
  static const Color divineSurface = Color(0xFFFFFDF0);    // Light ivory for cards
  
  // Text Colors
  static const Color textBlack = Color(0xFF2D2D2D);       // Ink black
  static const Color textGrey = Color(0xFF5D5D5D);        // Muted ink
  static const Color textLight = Color(0xFF9E9E9E);       // Faded ink

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
  
  // Dark theme palette
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF808080);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: divineGoldLight,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        primary: divineGoldLight,
        secondary: divineGold,
        surface: darkSurface,
        onPrimary: divinePrimary,
        onSecondary: divinePrimary,
        onSurface: darkTextPrimary,
        background: darkBackground,
        error: errorRed,
        outline: Colors.white.withOpacity(0.1),
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: TextTheme(
        displayLarge: titleStyle.copyWith(color: darkTextPrimary, fontSize: 40, height: 1.1),
        displayMedium: titleStyle.copyWith(color: darkTextPrimary, fontSize: 32, height: 1.2),
        displaySmall: titleStyle.copyWith(color: darkTextPrimary, fontSize: 28, height: 1.2),
        headlineLarge: titleStyle.copyWith(color: darkTextPrimary, fontSize: 24, fontWeight: FontWeight.w600),
        headlineMedium: titleStyle.copyWith(color: darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: bodyStyle.copyWith(color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        titleMedium: bodyStyle.copyWith(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: bodyStyle.copyWith(color: darkTextPrimary, fontSize: 16),
        bodyMedium: bodyStyle.copyWith(color: darkTextSecondary, fontSize: 14),
        bodySmall: bodyStyle.copyWith(color: darkTextSecondary, fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: titleStyle.copyWith(color: darkTextPrimary, fontSize: 20),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: divineGold,
          foregroundColor: divinePrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: bodyStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 16, color: divinePrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: divineGoldLight,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          side: const BorderSide(color: divineGold, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: bodyStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 16, color: divineGoldLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        hintStyle: bodyStyle.copyWith(color: darkTextTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: divineGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
      ),
    );
  }

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
  // Headings: Architects Daughter - Sketchy, Creative.
  static TextStyle get titleStyle => GoogleFonts.architectsDaughter(
    color: textBlack,
    fontWeight: FontWeight.bold,
  );

  // Body: Patrick Hand - Friendly, Hand-drawn.
  static TextStyle get bodyStyle => GoogleFonts.patrickHand(
    color: textBlack,
    fontSize: 16,
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
    color: divineSurface.withOpacity(0.95),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.black.withOpacity(0.03)),
    boxShadow: softShadow,
  );

  static BoxDecoration get navBarGlass => BoxDecoration(
    color: Colors.white.withOpacity(0.2),
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 30,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.6),
        blurRadius: 2,
        offset: const Offset(0, -1),
      ),
    ],
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
      // Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: divineBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textBlack),
        titleTextStyle: titleStyle.copyWith(fontSize: 22),
      ),
      
      cardTheme: CardThemeData(
        color: divineSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: textBlack, width: 1.5),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: divinePrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: textBlack, width: 2),
          ),
          textStyle: bodyStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: divinePrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          side: const BorderSide(color: divinePrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: bodyStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: divineSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        hintStyle: bodyStyle.copyWith(color: textLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: textBlack, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: textBlack, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divineGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
      ),
    );
  }
}

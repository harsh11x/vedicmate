import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===========================================================================
  // PALETTE: MODERN VEDIC BRUTALISM
  // ===========================================================================

  static const Color divinePrimary = Color(0xFF11100E);
  static const Color divineInk = Color(0xFF17130F);
  static const Color divineGold = Color(0xFFD9902F);
  static const Color divineGoldLight = Color(0xFFF0B45A);
  static const Color sacredCopper = Color(0xFFB85C38);
  static const Color templeClay = Color(0xFF8C4B2F);
  static const Color lotusMist = Color(0xFFF4EEE5);
  static const Color sandalwood = Color(0xFFE8D4B8);
  static const Color deepOlive = Color(0xFF2F3A26);
  static const Color mantraBlue = Color(0xFF1B2A41);

  static const Color divineBackground = Color(0xFFF7F1E8);
  static const Color divineSurface = Color(0xFFFFFBF2);
  static const Color elevatedSurface = Color(0xFFFFFFFF);

  static const Color textBlack = Color(0xFF17130F);
  static const Color textGrey = Color(0xFF62584C);
  static const Color textLight = Color(0xFF9B8F80);

  // Status
  static const Color successGreen = Color(0xFF2E6F40); // Kept from Forest theme
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
  static const Color infoBlue = mantraBlue;
  static const Color primaryLight = divineGoldLight;
  static Color get shadowColor => Colors.black.withOpacity(0.08);

  // Missing Legacy Constants
  static const Color yellowPrimary = divineGold;
  static const Color goldAccent = divineGold;
  static const Color creamPrimary = divineSurface;
  static const Color textDark = textBlack;
  static const Color white = Colors.white;
  static const Color saffronPrimary = divineGold;
  static const Color celestialBlue = mantraBlue;
  static const Color celestialPurple = divinePrimary;
  static const Color deepSpaceGradient = divinePrimary; // Fallback
  static const Color cosmicGradient = divinePrimary; // Fallback
  static const Color warmGradient = divineGold; // Fallback

  // Dark theme palette
  static const Color darkBackground = Color(0xFF0D0C0A);
  static const Color darkSurface = Color(0xFF171411);
  static const Color darkSurfaceRaised = Color(0xFF211B16);
  static const Color darkTextPrimary = Color(0xFFF8EFE4);
  static const Color darkTextSecondary = Color(0xFFC9B9A6);
  static const Color darkTextTertiary = Color(0xFF887A68);

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
        outline: Colors.white.withOpacity(0.12),
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: TextTheme(
        displayLarge: titleStyle.copyWith(
            color: darkTextPrimary, fontSize: 42, height: 1.02),
        displayMedium: titleStyle.copyWith(
            color: darkTextPrimary, fontSize: 34, height: 1.08),
        displaySmall: titleStyle.copyWith(
            color: darkTextPrimary, fontSize: 28, height: 1.1),
        headlineLarge: titleStyle.copyWith(
            color: darkTextPrimary, fontSize: 25, fontWeight: FontWeight.w700),
        headlineMedium: titleStyle.copyWith(
            color: darkTextPrimary, fontSize: 21, fontWeight: FontWeight.w700),
        titleLarge: bodyStyle.copyWith(
            color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w800),
        titleMedium: bodyStyle.copyWith(
            color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w700),
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
        titleTextStyle: titleStyle.copyWith(
            color: darkTextPrimary, fontSize: 20, letterSpacing: -0.3),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: divineGoldLight,
          foregroundColor: divineInk,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: bodyStyle.copyWith(
              fontWeight: FontWeight.w800, fontSize: 15, color: divinePrimary),
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
          textStyle: bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: divineGoldLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceRaised,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        hintStyle: bodyStyle.copyWith(color: darkTextTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: divineGoldLight, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
      ),
    );
  }

  // More Legacy Mappings
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [divineInk, mantraBlue],
  );
  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [divineGoldLight, divineGold, sacredCopper],
  );
  static const Color neutralSoft = lotusMist;
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
  static TextStyle get titleStyle => GoogleFonts.spaceGrotesk(
        color: textBlack,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      );

  static TextStyle get bodyStyle => GoogleFonts.plusJakartaSans(
        color: textBlack,
        fontSize: 15,
        height: 1.35,
      );

  // ===========================================================================
  // SHADOWS & GLASS
  // ===========================================================================

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 10),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 32,
          offset: const Offset(0, 18),
          spreadRadius: -12,
        ),
        BoxShadow(
          color: divineGold.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ];

  static BoxDecoration get glassMorphism => BoxDecoration(
        color: elevatedSurface.withOpacity(0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: divineInk.withOpacity(0.08)),
        boxShadow: softShadow,
      );

  static BoxDecoration get navBarGlass => BoxDecoration(
        color: elevatedSurface.withOpacity(0.76),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: divineInk.withOpacity(0.10), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.75),
            blurRadius: 1,
            offset: const Offset(0, 1),
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
        outline: divineInk.withOpacity(0.12),
      ),

      // Typography System
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: TextTheme(
        displayLarge: titleStyle.copyWith(fontSize: 42, height: 1.02),
        displayMedium: titleStyle.copyWith(fontSize: 34, height: 1.08),
        displaySmall: titleStyle.copyWith(fontSize: 28, height: 1.1),
        headlineLarge:
            titleStyle.copyWith(fontSize: 25, fontWeight: FontWeight.w800),
        headlineMedium:
            titleStyle.copyWith(fontSize: 21, fontWeight: FontWeight.w800),
        titleLarge:
            bodyStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
        titleMedium:
            bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
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
        titleTextStyle: titleStyle.copyWith(fontSize: 21, letterSpacing: -0.3),
      ),

      cardTheme: CardThemeData(
        color: elevatedSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: divineInk.withOpacity(0.08), width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: divineInk,
          foregroundColor: divineSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle:
              bodyStyle.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: divinePrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          side: BorderSide(color: divineInk.withOpacity(0.20), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle:
              bodyStyle.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        hintStyle: bodyStyle.copyWith(color: textLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: divineInk.withOpacity(0.10), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: divineInk.withOpacity(0.10), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: divineGold, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lotusMist,
        selectedColor: divineInk,
        labelStyle:
            bodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
        secondaryLabelStyle: bodyStyle.copyWith(
            color: divineSurface, fontSize: 12, fontWeight: FontWeight.w700),
        side: BorderSide(color: divineInk.withOpacity(0.08)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: divineInk,
        contentTextStyle: bodyStyle.copyWith(
            color: divineSurface, fontWeight: FontWeight.w700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Steam palette
  static const Color steamDeepNavy = Color(0xFF171A21);
  static const Color steamNavy     = Color(0xFF1B2838);
  static const Color steamCard     = Color(0xFF1E2837);
  static const Color steamSlate    = Color(0xFF2A475E);
  static const Color steamCyan     = Color(0xFF66C0F4);
  static const Color steamBlue     = Color(0xFF4C94D4);
  static const Color steamGrey     = Color(0xFFC6D4DF);
  static const Color steamDimGrey  = Color(0xFF8F98A0);

  static ThemeData get darkTheme {
    final cs = ColorScheme.fromSeed(seedColor: steamCyan, brightness: Brightness.dark).copyWith(
      primary: steamCyan, onPrimary: steamDeepNavy,
      primaryContainer: steamSlate, onPrimaryContainer: steamGrey,
      secondary: steamBlue, onSecondary: steamDeepNavy,
      surface: steamNavy, onSurface: steamGrey,
      surfaceContainerHighest: steamCard, onSurfaceVariant: steamDimGrey,
      outline: steamSlate, outlineVariant: const Color(0xFF243447),
      error: const Color(0xFFFF4444), onError: Colors.white,
    );
    return ThemeData(
      useMaterial3: true, colorScheme: cs,
      scaffoldBackgroundColor: steamNavy, cardColor: steamCard,
      appBarTheme: const AppBarTheme(
        elevation: 0, centerTitle: false,
        backgroundColor: steamDeepNavy, foregroundColor: steamGrey,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(color: steamGrey, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
      cardTheme: const CardThemeData(
        elevation: 0, color: steamCard,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: steamCyan, foregroundColor: steamDeepNavy,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: steamCyan, foregroundColor: steamDeepNavy, elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: steamCyan, side: const BorderSide(color: steamCyan, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      )),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: steamCyan)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: steamDeepNavy,
        border: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: steamSlate.withOpacity(0.7))),
        enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: steamSlate.withOpacity(0.7))),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: steamCyan, width: 2)),
        labelStyle: const TextStyle(color: steamDimGrey), prefixIconColor: steamCyan,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: steamCyan, foregroundColor: steamDeepNavy, elevation: 0),
      iconTheme: const IconThemeData(color: steamCyan),
      dividerTheme: DividerThemeData(color: steamSlate.withOpacity(0.5), thickness: 1),
      listTileTheme: const ListTileThemeData(iconColor: steamCyan),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: steamCyan),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: steamSlate, contentTextStyle: const TextStyle(color: steamGrey),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: steamCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      expansionTileTheme: const ExpansionTileThemeData(iconColor: steamCyan, textColor: steamGrey),
    );
  }

  static ThemeData get lightTheme {
    const navy = Color(0xFF1A3A5C);
    final cs = ColorScheme.fromSeed(seedColor: navy, brightness: Brightness.light).copyWith(
      primary: navy, onPrimary: Colors.white,
      secondary: const Color(0xFF2980B9), onSecondary: Colors.white,
    );
    return ThemeData(
      useMaterial3: true, colorScheme: cs,
      appBarTheme: const AppBarTheme(
        elevation: 0, centerTitle: false, backgroundColor: navy, foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: cs.outline.withOpacity(0.15))),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: navy, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: navy, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      )),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: navy, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

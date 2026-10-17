import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract final class InventiColors {
  static const mint = Color(0xFF55C9A6);
  static const forest = Color(0xFF249878);
  static const mintLight = Color(0xFFE2F6EE);
  static const background = Color(0xFFF5F6F8);
  static const cream = background;
  static const peach = Color(0xFFFFD8C4);
  static const line = Color(0xFFD9DEE3);
  static const ink = Color(0xFF222222);
  static const muted = Color(0xFF666666);
  static const red = Color(0xFFE53935);
}

String money(int cents) => NumberFormat.currency(
  locale: 'en_US',
  symbol: 'S/ ',
  decimalDigits: 2,
).format(cents / 100);
String units(int value) => NumberFormat.decimalPattern('es_PE').format(value);

ThemeData buildTheme() {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(color: InventiColors.line),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: InventiColors.mint,
      primary: InventiColors.forest,
      onPrimary: Colors.white,
      primaryContainer: InventiColors.mintLight,
      onPrimaryContainer: InventiColors.forest,
      secondary: InventiColors.mint,
      surface: Colors.white,
      onSurface: InventiColors.ink,
      onSurfaceVariant: InventiColors.muted,
      outlineVariant: InventiColors.line,
      error: InventiColors.red,
    ),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w700,
        color: InventiColors.ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: InventiColors.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: InventiColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: InventiColors.ink,
      ),
      bodyLarge: TextStyle(fontSize: 15, color: InventiColors.ink),
      bodyMedium: TextStyle(fontSize: 14, color: InventiColors.ink),
      bodySmall: TextStyle(fontSize: 12, color: InventiColors.muted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: InventiColors.mint,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 56,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: InventiColors.mint, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: const TextStyle(fontSize: 14, color: InventiColors.muted),
      hintStyle: const TextStyle(fontSize: 14, color: InventiColors.muted),
      prefixIconColor: InventiColors.muted,
      suffixIconColor: InventiColors.muted,
      errorMaxLines: 3,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: InventiColors.mint,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: InventiColors.forest,
        backgroundColor: Colors.white,
        minimumSize: const Size(0, 46),
        side: const BorderSide(color: InventiColors.mint),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: InventiColors.forest),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: InventiColors.muted,
      textColor: InventiColors.ink,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    ),
    dividerTheme: const DividerThemeData(
      color: InventiColors.line,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: InventiColors.forest,
    ),
  );
}

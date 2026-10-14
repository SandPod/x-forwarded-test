import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens following serverpod.dev: white pages, gray text, a navy
/// feature panel, pink actions and a sky-to-pink highlight gradient.
abstract final class Palette {
  static const background = Color(0xFFFFFFFF);
  static const card = Color(0xFFF9FAFB); // gray-50
  static const border = Color(0xFFE5E7EB); // gray-200
  static const ink = Color(0xFF1F2937); // gray-800
  static const muted = Color(0xFF4B5563); // gray-600
  static const faint = Color(0xFF9CA3AF); // gray-400

  static const navy = Color(0xFF001432);
  static const pink = Color(0xFFDB2777); // pink-600
  static const pinkHover = Color(0xFFBE185D); // pink-700
  static const highlight = LinearGradient(
    colors: [Color(0xFFBAE6FD), Color(0xFFEC4899)], // sky-200 → pink-500
  );

  static const yes = Color(0xFF059669); // emerald-600
  static const yesBright = Color(0xFF34D399); // emerald-400, on navy
  static const yesSoft = Color(0xFFECFDF5);
  static const no = Color(0xFFDC2626); // red-600
  static const noBright = Color(0xFFF87171); // red-400, on navy
  static const noSoft = Color(0xFFFEF2F2);
}

abstract final class Fonts {
  /// Headings: Inter Black, as on serverpod.dev.
  static TextStyle display(double size, {Color color = Palette.ink}) =>
      GoogleFonts.inter(
        fontSize: size,
        color: color,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: -0.02 * size,
      );

  /// Body text.
  static TextStyle body(
    double size, {
    Color color = Palette.ink,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
  }) => GoogleFonts.inter(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
  );

  /// Monospace for addresses and header values.
  static TextStyle code(
    double size, {
    Color color = Palette.ink,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: 1.45,
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.pink,
      primary: Palette.pink,
      surface: Palette.background,
      onSurface: Palette.ink,
      error: Palette.no,
    ),
    scaffoldBackgroundColor: Palette.background,
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Palette.pink.withValues(alpha: 0.2),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Palette.navy,
      contentTextStyle: Fonts.body(
        14,
        color: Colors.white,
        weight: FontWeight.w600,
      ),
      shape: const StadiumBorder(),
      width: 260,
      elevation: 0,
    ),
  );
}

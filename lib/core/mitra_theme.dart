import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual tokens shared by the LokaTrip partner portal.
///
/// Manrope remains the portal typeface: it is already used throughout the
/// mitra screens and stays legible for both operational labels and numbers.
abstract final class MitraPalette {
  static const primary = Color(0xFF1748D1);
  static const primaryDark = Color(0xFF0F47D1);
  static const primaryLight = Color(0xFFEFF6FF);
  static const primaryBorder = Color(0xFFBFDBFE);
  static const accent = Color(0xFFFFC349);
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const line = Color(0xFFE2E8F0);
  static const canvas = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const success = Color(0xFF059669);
  static const warning = Color(0xFFB45309);
  static const danger = Color(0xFFDC2626);
}

abstract final class MitraMetrics {
  static const pageGutter = 20.0;
  static const contentMaxWidth = 800.0;
  static const cardRadius = 18.0;
  static const controlRadius = 12.0;
}

ThemeData mitraTheme(ThemeData base) {
  final scheme = ColorScheme.fromSeed(
    seedColor: MitraPalette.primary,
    brightness: Brightness.light,
    surface: MitraPalette.surface,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: MitraPalette.canvas,
    dividerColor: MitraPalette.line,
    textTheme: GoogleFonts.manropeTextTheme(
      base.textTheme,
    ).apply(bodyColor: MitraPalette.ink, displayColor: MitraPalette.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: MitraPalette.surface,
      foregroundColor: MitraPalette.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MitraPalette.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MitraMetrics.controlRadius),
        ),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MitraPalette.primary,
        side: const BorderSide(color: MitraPalette.primaryBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MitraMetrics.controlRadius),
        ),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MitraPalette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MitraMetrics.controlRadius),
        borderSide: const BorderSide(color: MitraPalette.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MitraMetrics.controlRadius),
        borderSide: const BorderSide(color: MitraPalette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MitraMetrics.controlRadius),
        borderSide: const BorderSide(color: MitraPalette.primary, width: 1.5),
      ),
    ),
  );
}

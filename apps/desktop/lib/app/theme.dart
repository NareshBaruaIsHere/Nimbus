import 'package:flutter/material.dart';

/// A restrained, neutral palette with a single accent. Avoids gradients,
/// heavy shadows and oversized radii in favour of clear hierarchy and borders.
class NimbusColors {
  NimbusColors._();

  // Dark
  static const darkBg = Color(0xFF0E0F12);
  static const darkSurface = Color(0xFF16181D);
  static const darkSurfaceVariant = Color(0xFF1C1F25);
  static const darkBorder = Color(0xFF26292F);
  static const darkText = Color(0xFFE7E9EC);
  static const darkTextMuted = Color(0xFF9AA0A8);
  static const darkAccent = Color(0xFF4C8DF5);

  // Light
  static const lightBg = Color(0xFFF7F8FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F3F5);
  static const lightBorder = Color(0xFFE3E6EA);
  static const lightText = Color(0xFF1A1D21);
  static const lightTextMuted = Color(0xFF5C636E);
  static const lightAccent = Color(0xFF2C6BED);

  // Status
  static const success = Color(0xFF3FB950);
  static const pending = Color(0xFFD29922);
  static const paused = Color(0xFF8B949E);
  static const failed = Color(0xFFF85149);
}

class NimbusRadius {
  NimbusRadius._();
  static const double small = 8.0;
  static const double medium = 10.0;
  static const double large = 14.0;
}

class NimbusTheme {
  NimbusTheme._();

  static const radius = 10.0;

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    bg: NimbusColors.darkBg,
    surface: NimbusColors.darkSurface,
    surfaceVariant: NimbusColors.darkSurfaceVariant,
    border: NimbusColors.darkBorder,
    text: NimbusColors.darkText,
    textMuted: NimbusColors.darkTextMuted,
    accent: NimbusColors.darkAccent,
  );

  static final ThemeData light = _build(
    brightness: Brightness.light,
    bg: NimbusColors.lightBg,
    surface: NimbusColors.lightSurface,
    surfaceVariant: NimbusColors.lightSurfaceVariant,
    border: NimbusColors.lightBorder,
    text: NimbusColors.lightText,
    textMuted: NimbusColors.lightTextMuted,
    accent: NimbusColors.lightAccent,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surfaceVariant,
    required Color border,
    required Color text,
    required Color textMuted,
    required Color accent,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: Colors.white,
      secondary: accent,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: textMuted,
      outline: border,
      outlineVariant: border,
      error: NimbusColors.failed,
      onError: Colors.white,
      shadow: Colors.transparent,
    );

    final textTheme = TextTheme(
      displaySmall: TextStyle(color: text, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      headlineMedium: TextStyle(color: text, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      headlineSmall: TextStyle(color: text, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleLarge: TextStyle(color: text, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: text, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: text, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: text, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(color: text, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(color: textMuted, fontWeight: FontWeight.w400),
      labelLarge: const TextStyle(fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: textMuted, fontWeight: FontWeight.w500),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      dividerColor: border,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: accent),
        ),
        hintStyle: TextStyle(color: textMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textMuted,
          hoverColor: brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: brightness == Brightness.dark ? NimbusColors.darkSurfaceVariant : NimbusColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border),
        ),
        textStyle: TextStyle(color: text),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    );
  }
}

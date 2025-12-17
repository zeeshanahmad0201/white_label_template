import 'package:core_platform/core/core.dart';
import 'package:flutter/material.dart';
import '../utils/size_utils.dart';

/// Client-specific theme scheme for white label branding
///
/// This allows each client to define their complete theme configuration
/// including text styles, button themes, input decoration, and more.
///
/// Example:
/// ```dart
/// class MyClientThemeScheme extends ClientThemeScheme {
///   @override
///   ThemeData buildLightTheme(ClientColorScheme colors) {
///     return ThemeData(
///       primaryColor: colors.primary,
///       // ... custom light theme
///     );
///   }
/// }
/// ```
abstract class ClientThemeScheme {
  /// Build the light theme for this client
  ThemeData buildLightTheme(ClientColorScheme colors);

  /// Build the dark theme for this client
  /// Returns null if the client doesn't support dark mode
  ThemeData? buildDarkTheme(ClientColorScheme colors);

  /// Optional: Custom text theme
  TextTheme? buildTextTheme(ClientColorScheme colors) => null;

  /// Optional: Custom elevated button theme
  ElevatedButtonThemeData? buildElevatedButtonTheme(ClientColorScheme colors) =>
      null;

  /// Optional: Custom input decoration theme
  InputDecorationTheme? buildInputDecorationTheme(ClientColorScheme colors,
      {required bool isDark}) => null;

  /// Optional: Custom card theme
  CardTheme? buildCardTheme(ClientColorScheme colors, {required bool isDark}) =>
      null;

  /// Optional: Custom app bar theme
  AppBarTheme? buildAppBarTheme(ClientColorScheme colors,
      {required bool isDark}) => null;

  /// Optional: Font family override
  String? get fontFamily => null;

  /// Optional: Use Material 3 design system
  bool get useMaterial3 => true;

  /// Optional: Default border radius for components
  double get defaultBorderRadius => 8.0;

  /// Optional: Default elevation for components
  double get defaultElevation => 2.0;
}

/// Default theme scheme implementation
class DefaultClientThemeScheme extends ClientThemeScheme {
  @override
  TextTheme? buildTextTheme(ClientColorScheme colors) {
    // Create a custom text theme with responsive sizing
    return TextTheme(
      // Display styles - for hero text and main headlines
      displayLarge: TextStyle(
        fontSize: 32.fSize,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 24.fSize,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.3,
      ),
      displaySmall: TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.3,
      ),

      // Headline styles - for page titles and section headers
      headlineLarge: TextStyle(
        fontSize: 18.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.4,
      ),
      headlineMedium: TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.4,
      ),

      // Body styles - for main content
      bodyLarge: TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: colors.onSurface.withOpacity(0.8),
        height: 1.4,
      ),

      // Label styles - for form labels, tags, captions
      labelLarge: TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.3,
      ),
      labelMedium: TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.3,
      ),
      labelSmall: TextStyle(
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
        color: colors.onSurface.withOpacity(0.7),
        height: 1.3,
      ),

      // Title styles - for list items, card titles
      titleLarge: TextStyle(
        fontSize: 18.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
        color: colors.onSurface,
        height: 1.4,
      ),
    );
  }

  @override
  ThemeData buildLightTheme(ClientColorScheme colors) {
    final textTheme = buildTextTheme(colors);
    final elevatedButtonTheme = buildElevatedButtonTheme(colors);
    final inputDecorationTheme = buildInputDecorationTheme(
        colors, isDark: false);
    final cardTheme = buildCardTheme(colors, isDark: false);
    final appBarTheme = buildAppBarTheme(colors, isDark: false);

    return ThemeData(
      useMaterial3: useMaterial3,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.secondary,
        error: colors.error,
        surface: colors.surface,
        onPrimary: colors.onPrimary,
        onSecondary: colors.onPrimary,
        // Use onPrimary as default
        onSurface: colors.onSurface,
        onError: colors.onError,
      ),
      textTheme: textTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
      cardTheme: cardTheme,
      appBarTheme: appBarTheme,
      fontFamily: fontFamily,
    );
  }

  @override
  ThemeData? buildDarkTheme(ClientColorScheme colors) {
    // If client doesn't provide dark colors, dark mode is not supported
    if (!colors.supportsDarkMode) {
      return null;
    }
    final textTheme = buildTextTheme(colors);
    final elevatedButtonTheme = buildElevatedButtonTheme(colors);
    final inputDecorationTheme = buildInputDecorationTheme(
        colors, isDark: true);
    final cardTheme = buildCardTheme(colors, isDark: true);
    final appBarTheme = buildAppBarTheme(colors, isDark: true);

    return ThemeData(
      useMaterial3: useMaterial3,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.backgroundDark!,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.secondary,
        error: colors.error,
        surface: colors.surfaceDark!,
        onPrimary: colors.onPrimary,
        onSecondary: colors.onPrimary,
        // Use onPrimary as default
        onSurface: colors.onSurfaceDark!,
        onError: colors.onError,
      ),
      textTheme: textTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
      cardTheme: cardTheme,
      appBarTheme: appBarTheme,
      fontFamily: fontFamily,
    );
  }

  @override
  ElevatedButtonThemeData buildElevatedButtonTheme(ClientColorScheme colors) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colors.onPrimary,
        backgroundColor: colors.primary,
        elevation: defaultElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
    );
  }

  @override
  InputDecorationTheme buildInputDecorationTheme(ClientColorScheme colors,
      {required bool isDark}) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        borderSide: BorderSide(
          color: isDark ? (colors.surfaceDark ?? colors.surface) : colors
              .surface,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        borderSide: BorderSide(
          color: isDark ? (colors.surfaceDark ?? colors.surface) : colors
              .surface,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        borderSide: BorderSide(
          color: colors.primary,
          width: 2,
        ),
      ),
    );
  }

  @override
  CardTheme buildCardTheme(ClientColorScheme colors, {required bool isDark}) {
    return CardTheme(
      color: isDark ? colors.surfaceDark ?? colors.surface : colors.surface,
      elevation: defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
    );
  }

  @override
  AppBarTheme buildAppBarTheme(ClientColorScheme colors,
      {required bool isDark}) {
    return AppBarTheme(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      elevation: 0,
      centerTitle: true,
    );
  }
}
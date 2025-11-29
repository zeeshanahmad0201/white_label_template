import 'package:flutter/material.dart';

/// Foundation color scheme for white label theming
///
/// This defines the minimal set of colors that each client must provide.
/// All other colors in the app are derived from these foundation colors,
/// ensuring consistent theming while allowing complete brand customization.
abstract class ClientColorScheme {
  // ============================================================================
  // BRAND COLORS (2 colors)
  // ============================================================================

  /// Primary brand color - used for main actions, focus states, primary buttons
  Color get primary;

  /// Secondary brand color - used for accents, secondary actions
  Color get secondary;

  // ============================================================================
  // SURFACE COLORS (3 colors)
  // ============================================================================

  /// Main background color - used for scaffold backgrounds
  Color get background;

  /// Surface color - used for cards, dialogs, elevated surfaces
  Color get surface;

  /// Content color on surfaces - used for text and icons on surface/background
  Color get onSurface;

  // ============================================================================
  // STATUS COLORS (2 colors)
  // ============================================================================

  /// Error color - used for error messages, validation failures
  Color get error;

  /// Success color - used for success messages, completed states
  Color get success;

  // ============================================================================
  // OPTIONAL CUSTOMIZATIONS
  // ============================================================================

  /// Custom splash screen gradient (optional)
  ///
  /// If null, a gradient will be automatically generated from the primary color.
  /// Clients can override this to provide complete control over gradient appearance
  /// including colors, stops, alignment, and other properties.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// LinearGradient? get splashGradient => LinearGradient(
  ///   begin: Alignment.topLeft,
  ///   end: Alignment.bottomRight,
  ///   colors: [
  ///     Color(0xFFFF6B6B), // Light red
  ///     Color(0xFFE74C3C), // Medium red
  ///     Color(0xFFC0392B), // Dark red
  ///   ],
  ///   stops: [0.0, 0.7, 1.0], // Custom stops for precise control
  /// );
  /// ```
  LinearGradient? get splashGradient => null;

  // ============================================================================
  // COMPUTED PROPERTIES
  // ============================================================================

  /// Whether this is a dark theme (computed from background brightness)
  bool get isDark => ThemeData.estimateBrightnessForColor(background) == Brightness.dark;

  /// On-primary color (computed for optimal contrast)
  Color get onPrimary => _getContrastColor(primary);

  /// On-error color (computed for optimal contrast)
  Color get onError => _getContrastColor(error);

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Get contrasting color (white or black) for optimal readability
  Color _getContrastColor(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
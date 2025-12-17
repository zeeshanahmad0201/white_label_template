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
  // DARK MODE COLORS (Optional - set ALL or NONE)
  // ============================================================================

  /// Dark mode background color
  /// If null, dark mode will not be available for this client
  Color? get backgroundDark => null;

  /// Dark mode surface color
  /// Required if backgroundDark is provided
  Color? get surfaceDark => null;

  /// Dark mode content color on surfaces
  /// Required if backgroundDark is provided
  Color? get onSurfaceDark => null;

  /// Whether this client supports dark mode
  bool get supportsDarkMode => backgroundDark != null && surfaceDark != null && onSurfaceDark != null;

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

  /// On-primary color (customizable, defaults to optimal contrast)
  ///
  /// Override this to specify exactly what color should appear on primary backgrounds.
  /// Common choices: Colors.white, Colors.black, or your brand's contrast color.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Color get onPrimary => Colors.white; // Force white text on primary
  /// ```
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
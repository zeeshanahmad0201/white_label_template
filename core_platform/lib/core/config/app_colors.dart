import 'package:flutter/material.dart';
import 'client_color_scheme.dart';

/// Semantic color system that derives all colors from a ClientColorScheme
///
/// This class provides a complete color palette by deriving colors from the
/// minimal foundation colors defined in ClientColorScheme. This ensures:
/// - Consistent color relationships across all clients
/// - Automatic accessibility compliance
/// - Single source of truth for all colors
/// - Easy white label customization
class DerivedAppColors {
  final ClientColorScheme _scheme;

  const DerivedAppColors(this._scheme);

  // ============================================================================
  // BRAND COLORS (from foundation)
  // ============================================================================

  Color get primary => _scheme.primary;
  Color get secondary => _scheme.secondary;
  Color get onPrimary => _scheme.onPrimary;

  // ============================================================================
  // SURFACE COLORS (from foundation)
  // ============================================================================

  Color get background => _scheme.background;
  Color get surface => _scheme.surface;
  Color get onSurface => _scheme.onSurface;
  Color get onBackground => _scheme.onSurface; // Same as onSurface for consistency

  // ============================================================================
  // STATUS COLORS (from foundation)
  // ============================================================================

  Color get error => _scheme.error;
  Color get success => _scheme.success;
  Color get onError => _scheme.onError;

  // ============================================================================
  // TEXT COLORS (derived from onSurface)
  // ============================================================================

  Color get textPrimary => onSurface;
  Color get textSecondary => onSurface.withValues(alpha: 0.7);
  Color get textHint => onSurface.withValues(alpha: 0.5);
  Color get textDisabled => onSurface.withValues(alpha: 0.38);

  // ============================================================================
  // BORDER COLORS (derived from onSurface)
  // ============================================================================

  Color get border => onSurface.withValues(alpha: 0.2);
  Color get divider => onSurface.withValues(alpha: 0.15);

  // ============================================================================
  // INPUT COLORS (derived from primary and border)
  // ============================================================================

  Color get inputBorderInactive => border;
  Color get inputBorderActive => primary;

  // ============================================================================
  // UI COLORS (derived combinations)
  // ============================================================================

  Color get disabled => onSurface.withValues(alpha: 0.38);
  Color get shadowColor => onSurface.withValues(alpha: 0.1);

  // Common UI colors
  Color get white => Colors.white;

  // Backwards compatibility aliases
  Color get primaryText => textPrimary;
  Color get onPrimaryContainer => surface;

  // ============================================================================
  // SPLASH SCREEN COLORS
  // ============================================================================

  /// Splash screen gradient
  ///
  /// Returns client's custom gradient if provided, otherwise generates
  /// a beautiful gradient from the primary color automatically.
  LinearGradient get splashGradient {
    // Use client's custom gradient if provided
    if (_scheme.splashGradient != null) {
      return _scheme.splashGradient!;
    }

    // Generate automatic gradient from primary color
    final HSLColor hsl = HSLColor.fromColor(primary);

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        // Light variant (increase lightness by 10%)
        hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0)).toColor(),
        // Original color
        primary,
        // Dark variant (decrease lightness by 10%)
        hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor(),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // ============================================================================
  // MATERIAL DESIGN HELPERS
  // ============================================================================

  /// Generate MaterialColor from primary color for Material Design compatibility
  MaterialColor get primarySwatch => MaterialColor(
    primary.value,
    <int, Color>{
      50: primary.withValues(alpha: 0.1),
      100: primary.withValues(alpha: 0.2),
      200: primary.withValues(alpha: 0.3),
      300: primary.withValues(alpha: 0.4),
      400: primary.withValues(alpha: 0.5),
      500: primary,
      600: primary.withValues(alpha: 0.7),
      700: primary.withValues(alpha: 0.8),
      800: primary.withValues(alpha: 0.9),
      900: primary.withValues(alpha: 1.0),
    },
  );
}
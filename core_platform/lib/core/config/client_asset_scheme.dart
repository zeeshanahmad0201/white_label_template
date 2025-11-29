/// Client-specific asset scheme for white label customization
///
/// This allows clients to define their brand assets while providing
/// sensible defaults and fallbacks for optional assets.
///
/// Usage:
/// ```dart
/// class MyClientAssetScheme implements ClientAssetScheme {
///   @override
///   String get appLogo => 'assets/images/my_logo.png';
///
///   @override
///   String get splashBackground => 'assets/images/my_splash.jpg';
///
///   // Optional assets use defaults if not overridden
/// }
/// ```
abstract class ClientAssetScheme {
  // ============================================================================
  // REQUIRED ASSETS
  // ============================================================================

  /// App logo - displayed in app bar and branding areas
  String get appLogo;

  /// Splash screen background image
  String get splashBackground;

  // ============================================================================
  // OPTIONAL ASSETS (with defaults)
  // ============================================================================

  /// Login screen background (optional)
  /// If null, will use a generated gradient background
  String? get loginBackground => null;

  /// Splash screen header graphic (optional)
  /// If null, will not display additional header graphic
  String? get splashHeader => null;

  /// Splash screen foreground graphic (optional)
  /// If null, will not display foreground overlay
  String? get splashForeground => null;

  /// Empty state illustration (optional)
  /// If null, will use default empty state icon
  String? get emptyStateIllustration => null;

  /// Error state illustration (optional)
  /// If null, will use default error icon
  String? get errorStateIllustration => null;
}
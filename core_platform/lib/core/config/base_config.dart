import 'package:firebase_core/firebase_core.dart';

import 'client_asset_scheme.dart';
import 'client_color_scheme.dart';
import 'client_design_scheme.dart';
import 'client_theme_scheme.dart';
import 'client_translation_scheme.dart';

/// Base configuration for white label clients
///
/// This abstract class defines all the customization points that clients
/// can override to create their branded version of the app.
///
/// Usage:
/// ```dart
/// class MyClientConfig extends BaseConfig {
///   @override
///   String get clientId => 'myclient';
///
///   @override
///   ClientColorScheme get colorScheme => MyClientColorScheme();
///
///   @override
///   ClientAssetScheme get assetScheme => MyClientAssetScheme();
///
///   // ... other required properties
/// }
/// ```
abstract class BaseConfig {
  // ============================================================================
  // CLIENT IDENTIFICATION
  // ============================================================================

  /// Unique client identifier (used for analytics, logging, etc.)
  String get clientId;

  /// Display name of the application
  String get appName;

  /// Package name for the application (com.company.app)
  String get packageName;

  /// Project name (used for grouping multiple apps)
  String get projectName;

  // ============================================================================
  // INFRASTRUCTURE CONFIGURATION
  // ============================================================================

  /// API base URL for backend services
  String get apiBaseUrl;

  /// Firebase configuration options
  /// Generate this using `flutterfire configure`
  FirebaseOptions get firebaseOptions;

  // ============================================================================
  // WHITE LABEL CUSTOMIZATION SCHEMES
  // ============================================================================

  /// Client-specific color scheme for theming
  ClientColorScheme get colorScheme;

  /// Client-specific asset scheme for branding
  ClientAssetScheme get assetScheme;

  /// Client-specific translation overrides for branding (optional)
  ClientTranslationScheme get translationScheme => const DefaultClientTranslationScheme();

  /// Client-specific theme scheme for complete theme customization (optional)
  ClientThemeScheme get themeScheme => DefaultClientThemeScheme();

  /// Client-specific design scheme for responsive sizing (optional)
  ClientDesignScheme get designScheme => DefaultClientDesignScheme();

  // ============================================================================
  // FEATURE FLAGS (optional)
  // ============================================================================

  /// Enable analytics tracking (default: true)
  bool get enableAnalytics => true;

  /// Enable crash reporting (default: true)
  bool get enableCrashlytics => true;

  /// Enable debug logging in release mode (default: false)
  bool get enableDebugLogging => false;

  /// API timeout in milliseconds (default: 30 seconds)
  int get apiTimeoutMs => 30000;
}
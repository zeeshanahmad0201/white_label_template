/// Client-specific translation overrides for white label customization
///
/// This allows clients to override specific branding and messaging
/// while keeping all other translations from the core platform.
///
/// Usage:
/// ```dart
/// class MyClientTranslationScheme implements ClientTranslationScheme {
///   @override
///   Map<String, Map<String, String>> get translationOverrides => {
///     'en': {
///       'appName': 'My Brand App',
///       'welcomeMessage': 'Welcome to My Brand!',
///       'splashHeader': 'Experience Excellence',
///     },
///     'es': {
///       'appName': 'Mi Aplicación de Marca',
///       'welcomeMessage': '¡Bienvenido a Mi Marca!',
///       'splashHeader': 'Experimenta la Excelencia',
///     },
///   };
/// }
/// ```
abstract class ClientTranslationScheme {
  /// Translation overrides by locale
  ///
  /// Format: {locale: {key: value}}
  /// Only include keys you want to override - all others fall back to core translations
  Map<String, Map<String, String>> get translationOverrides;

  /// Common branding keys that clients typically customize
  static const Set<String> brandingKeys = {
    'appName',
    'welcomeMessage',
    'splashHeader',
    'splashSubtitle',
  };
}

/// Default implementation - no overrides (uses core translations only)
class DefaultClientTranslationScheme implements ClientTranslationScheme {
  const DefaultClientTranslationScheme();

  @override
  Map<String, Map<String, String>> get translationOverrides => {};
}
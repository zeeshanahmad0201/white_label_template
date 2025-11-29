import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/base_config.dart';
import '../config/client_asset_scheme.dart';
import '../config/client_color_scheme.dart';
import '../config/client_translation_scheme.dart';
import '../cubits/client/client_cubit.dart';
import '../cubits/client/client_state.dart';

/// Extension to provide clean access to client data throughout the app
extension ClientContext on BuildContext {
  /// Get the current client state
  ClientState get client => read<ClientCubit>().state;

  /// Quick access to client configuration
  BaseConfig get clientConfig => client.config;

  /// Quick access to client color scheme
  ClientColorScheme get colorScheme => client.config.colorScheme;

  /// Quick access to client asset scheme
  ClientAssetScheme get assetScheme => client.config.assetScheme;

  /// Quick access to client translation scheme
  ClientTranslationScheme get translationScheme => client.config.translationScheme;

  /// Get client-specific translation or fallback to key
  String clientTranslation(String key, {String? locale}) {
    final currentLocale = locale ?? Localizations.localeOf(this).languageCode;
    return client.config.translationScheme
        .translationOverrides[currentLocale]?[key] ?? key;
  }

  /// Check if client has custom translation for key
  bool hasClientTranslation(String key, {String? locale}) {
    final currentLocale = locale ?? Localizations.localeOf(this).languageCode;
    return client.config.translationScheme
        .translationOverrides[currentLocale]?.containsKey(key) ?? false;
  }
}

/// Extension for easier color access in widgets
extension ColorContext on BuildContext {
  /// Quick color access - theme colors
  ColorScheme get colors => Theme.of(this).colorScheme;
}

/// Extension for easier text theme access
extension TextThemeContext on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}
import 'package:flutter/material.dart';

abstract class BaseConfig {
  String get clientId;
  String get appName;
  String get packageName;
  String get projectName;

  Color get primaryColor;
  Color get secondaryColor;

  String get apiBaseUrl;
  Map<String, dynamic> get firebaseConfig;
  Map<String, String> get customStrings;

  ThemeData get theme => ThemeData(
    primarySwatch: MaterialColor(primaryColor.value, {
      50: primaryColor.withOpacity(0.1),
      100: primaryColor.withOpacity(0.2),
      200: primaryColor.withOpacity(0.3),
      300: primaryColor.withOpacity(0.4),
      400: primaryColor.withOpacity(0.5),
      500: primaryColor,
      600: primaryColor.withOpacity(0.7),
      700: primaryColor.withOpacity(0.8),
      800: primaryColor.withOpacity(0.9),
      900: primaryColor.withOpacity(1.0),
    }),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: secondaryColor,
    ),
    useMaterial3: true,
  );
}
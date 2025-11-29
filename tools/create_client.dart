#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption('client-id', abbr: 'c', help: 'Client identifier (lowercase, underscores)', mandatory: true)
    ..addOption('app-name', abbr: 'n', help: 'Human readable app name', mandatory: true)
    ..addOption('project-name', abbr: 'p', help: 'Base project name (e.g., business_directory, food_delivery)', mandatory: true)
    ..addOption('org', abbr: 'o', help: 'Organization domain', defaultsTo: 'com.example')
    ..addFlag('help', abbr: 'h', help: 'Show usage information');

  try {
    final results = parser.parse(args);

    if (results['help'] || args.isEmpty) {
      _showUsage(parser);
      return;
    }

    final clientId = results['client-id'] as String;
    final appName = results['app-name'] as String;
    final projectName = results['project-name'] as String;
    final org = results['org'] as String;

    // Validate inputs
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(clientId)) {
      print('Error: client-id must be lowercase letters, numbers, and underscores only');
      exit(1);
    }

    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(projectName)) {
      print('Error: project-name must be lowercase letters, numbers, and underscores only');
      exit(1);
    }

    _createClient(clientId, appName, projectName, org);

  } catch (e) {
    print('Error: $e\n');
    _showUsage(parser);
    exit(1);
  }
}

void _showUsage(ArgParser parser) {
  print('White Label Client Generator\n');
  print('Usage: dart tools/create_client.dart [options]\n');
  print('Options:');
  print(parser.usage);
  print('\nExamples:');
  print('  # Business directory for NYC');
  print('  dart tools/create_client.dart -c nyc_biz -n "NYC Business Directory" -p business_directory');
  print('');
  print('  # Food delivery for Chicago');
  print('  dart tools/create_client.dart -c chicago_eats -n "Chicago Food Delivery" -p food_delivery');
  print('');
  print('  # Custom organization');
  print('  dart tools/create_client.dart -c miami_hotels -n "Miami Hotels" -p hotel_booking -o com.yourcompany');
  print('');
  print('Generated package: {org}.{project-name}.{client-id}');
  print('Generated location: clients/{client-id}/');
}

void _createClient(String clientId, String appName, String projectName, String org) {
  final packageName = '$org.$projectName.$clientId';
  final flutterProjectName = '${projectName}_$clientId';
  final apiUrl = 'https://api.example.com/$projectName';

  print('Creating white-label client...');
  print('├─ Client ID: $clientId');
  print('├─ App Name: $appName');
  print('├─ Project: $projectName');
  print('├─ Package: $packageName');
  print('└─ Flutter Project: $flutterProjectName\n');

  // Check if client already exists
  final clientDir = Directory('clients/$clientId');
  if (clientDir.existsSync()) {
    print('Error: Client $clientId already exists in clients/ folder!');
    exit(1);
  }

  // Check if core platform exists
  final corePlatformDir = Directory('core_platform');
  if (!corePlatformDir.existsSync()) {
    print('Error: core_platform/ not found. Run this script from the white-label root directory.');
    exit(1);
  }

  // 1. Use flutter create to generate complete project
  print('Creating Flutter project with flutter create...');
  final result = Process.runSync('flutter', [
    'create',
    '--project-name', flutterProjectName,
    '--org', org,
    '--platforms', 'android,ios,web',
    'clients/$clientId'
  ]);

  if (result.exitCode != 0) {
    print('Flutter create failed:');
    print(result.stderr);
    exit(1);
  }

  print('Flutter project created');

  // 2. Update files
  _addDependencies(clientDir);
  _createClientConfig(clientDir, clientId, appName, packageName, apiUrl);
  _createClientColorScheme(clientDir, clientId);
  _createClientAssetScheme(clientDir, clientId);
  _createMainDart(clientDir, clientId);

  print('\nClient $clientId created successfully!');
  print('Location: clients/$clientId');
  print('Package: $packageName');
  print('\nNext steps:');
  print('   1. cd clients/$clientId');
  print('   2. Customize color scheme and assets');
  print('   3. flutter run');
}

void _addDependencies(Directory clientDir) {
  print('Adding dependencies...');

  // Add core dependencies using flutter pub add
  final addResult = Process.runSync('flutter', [
    'pub', 'add',
    '--directory', clientDir.path,
    'flutter_bloc',
    'equatable'
  ]);

  if (addResult.exitCode != 0) {
    print('Failed to add dependencies. Ensure Flutter SDK is available: ${addResult.stderr}');
    exit(1);
  }

  // Add local core_platform dependency (needs different approach)
  final pubspecFile = File('${clientDir.path}/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found');
    exit(1);
  }

  // Read current pubspec
  String pubspecContent = pubspecFile.readAsStringSync();

  // Add core_platform dependency
  final coreDepLine = '  core_platform:\n    path: ../../core_platform\n';

  if (!pubspecContent.contains('core_platform:')) {
    // Find dependencies section and add core_platform
    if (pubspecContent.contains('dependencies:')) {
      pubspecContent = pubspecContent.replaceFirst(
        'dependencies:\n  flutter:\n    sdk: flutter',
        'dependencies:\n  flutter:\n    sdk: flutter\n$coreDepLine'
      );
      pubspecFile.writeAsStringSync(pubspecContent);
    }
  }

  // Add assets section if not exists
  if (!pubspecContent.contains('assets:')) {
    final assetSection = '''
  assets:
    - assets/images/
''';

    if (pubspecContent.contains('flutter:')) {
      pubspecContent = pubspecFile.readAsStringSync(); // Re-read after core_platform addition
      pubspecContent = pubspecContent.replaceFirst(
        'flutter:\n  uses-material-design: true',
        'flutter:\n  uses-material-design: true$assetSection'
      );
      pubspecFile.writeAsStringSync(pubspecContent);
    }
  }

  // Run flutter pub get to ensure all dependencies are resolved
  final pubGetResult = Process.runSync('flutter', [
    'pub', 'get',
  ], workingDirectory: clientDir.path);

  if (pubGetResult.exitCode != 0) {
    print('Warning: Failed to run flutter pub get: ${pubGetResult.stderr}');
  }

  print('Dependencies added');
}

void _createClientConfig(Directory clientDir, String clientId, String appName, String packageName, String apiUrl) {
  final configFile = File('${clientDir.path}/lib/client_config.dart');
  final className = _toPascalCase('${clientId}_config');

  configFile.writeAsStringSync('''
import 'package:core_platform/core/config/base_config.dart';
import 'client_color_scheme.dart';
import 'client_asset_scheme.dart';

class $className extends BaseConfig {
  @override
  String get clientId => '$clientId';

  @override
  String get appName => '$appName';

  @override
  String get packageName => '$packageName';

  @override
  String get apiBaseUrl => '$apiUrl';

  @override
  ClientColorScheme get colorScheme => ${_toPascalCase('${clientId}_color_scheme')}();

  @override
  ClientAssetScheme get assetScheme => ${_toPascalCase('${clientId}_asset_scheme')}();
}
''');
}

void _createClientColorScheme(Directory clientDir, String clientId) {
  final colorFile = File('${clientDir.path}/lib/client_color_scheme.dart');
  final className = _toPascalCase('${clientId}_color_scheme');

  colorFile.writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:core_platform/core/config/client_color_scheme.dart';

class $className extends ClientColorScheme {
  @override
  Color get primary => const Color(0xFF2196F3); // Blue - customize for your brand

  @override
  Color get secondary => const Color(0xFF03DAC6); // Teal - customize for your brand

  @override
  Color get background => Colors.white;

  @override
  Color get surface => const Color(0xFFFAFAFA);

  @override
  Color get onSurface => Colors.black87;

  @override
  Color get error => const Color(0xFFD32F2F);

  @override
  Color get success => const Color(0xFF4CAF50);

  // Optional: Custom splash gradient
  // @override
  // LinearGradient? get splashGradient => LinearGradient(
  //   colors: [primary.withOpacity(0.8), primary],
  //   begin: Alignment.topCenter,
  //   end: Alignment.bottomCenter,
  // );
}
''');
}

void _createClientAssetScheme(Directory clientDir, String clientId) {
  final assetFile = File('${clientDir.path}/lib/client_asset_scheme.dart');
  final className = _toPascalCase('${clientId}_asset_scheme');

  assetFile.writeAsStringSync('''
import 'package:core_platform/core/config/client_asset_scheme.dart';

class $className extends ClientAssetScheme {
  @override
  String get appLogo => 'assets/images/logo.png';

  @override
  String get splashBackground => 'assets/images/splash_bg.png';

  // Optional assets
  // @override
  // String? get loginBackground => 'assets/images/login_bg.png';
}
''');

  // Create placeholder assets directory and files
  final assetsDir = Directory('${clientDir.path}/assets/images');
  assetsDir.createSync(recursive: true);

  // Create asset README
  File('${assetsDir.path}/README.md').writeAsStringSync('''
# Client Assets

## Required Assets:
- logo.png - App logo (512x512 recommended)
- splash_bg.png - Splash screen background

## Optional Assets:
- login_bg.png - Login screen background

Add your client-specific assets here and update client_asset_scheme.dart accordingly.
''');
}

void _createMainDart(Directory clientDir, String clientId) {
  final mainFile = File('${clientDir.path}/lib/main.dart');
  final className = _toPascalCase('${clientId}_config');

  mainFile.writeAsStringSync('''
import 'package:core_platform/main_runner.dart';
import 'client_config.dart';

Future<void> main() => MainRunner.run(config: $className());
''');
}

String _toPascalCase(String text) {
  return text.split('_').map((word) =>
  word[0].toUpperCase() + word.substring(1).toLowerCase()
  ).join('');
}
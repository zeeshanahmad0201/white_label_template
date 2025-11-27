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
      print('❌ Error: client-id must be lowercase letters, numbers, and underscores only');
      exit(1);
    }

    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(projectName)) {
      print('❌ Error: project-name must be lowercase letters, numbers, and underscores only');
      exit(1);
    }

    _createClient(clientId, appName, projectName, org);

  } catch (e) {
    print('❌ Error: $e\n');
    _showUsage(parser);
    exit(1);
  }
}

void _showUsage(ArgParser parser) {
  print('🚀 White Label Client Generator\n');
  print('Usage: dart tools/create_client.dart [options]\n');
  print('Options:');
  print(parser.usage);
  print('\n📝 Examples:');
  print('  # Business directory for NYC');
  print('  dart tools/create_client.dart -c nyc_biz -n "NYC Business Directory" -p business_directory');
  print('');
  print('  # Food delivery for Chicago');
  print('  dart tools/create_client.dart -c chicago_eats -n "Chicago Food Delivery" -p food_delivery');
  print('');
  print('  # Custom organization');
  print('  dart tools/create_client.dart -c miami_hotels -n "Miami Hotels" -p hotel_booking -o com.yourcompany');
  print('');
  print('📦 Generated package: {org}.{project-name}.{client-id}');
  print('📁 Generated location: clients/{client-id}/');
}

void _createClient(String clientId, String appName, String projectName, String org) {
  final packageName = '$org.$projectName.$clientId';
  final flutterProjectName = '${projectName}_$clientId';

  print('🚀 Creating white-label client...');
  print('├─ Client ID: $clientId');
  print('├─ App Name: $appName');
  print('├─ Project: $projectName');
  print('├─ Package: $packageName');
  print('└─ Flutter Project: $flutterProjectName\n');

  // Check if client already exists
  final clientDir = Directory('clients/$clientId');
  if (clientDir.existsSync()) {
    print('❌ Error: Client $clientId already exists in clients/ folder!');
    exit(1);
  }

  // Check if core platform exists
  final corePlatformDir = Directory('core_platform');
  if (!corePlatformDir.existsSync()) {
    print('❌ Error: core_platform/ not found. Run this script from the white-label root directory.');
    exit(1);
  }

  // 1. Use flutter create to generate complete project
  print('📱 Creating Flutter project with flutter create...');
  final result = Process.runSync('flutter', [
    'create',
    '--project-name', flutterProjectName,
    '--org', org,
    '--platforms', 'android,ios,web',
    'clients/$clientId'
  ]);

  if (result.exitCode != 0) {
    print('❌ Flutter create failed:');
    print(result.stderr);
    exit(1);
  }

  print('✅ Flutter project created');

  // 2. Update files
  _updatePubspec(clientDir, flutterProjectName, appName);
  _createClientConfig(clientDir, clientId, appName, packageName, projectName);
  _createMainDart(clientDir, clientId, projectName);
  _copyAssets(clientDir);

  print('\n🎉 Client $clientId created successfully!');
  print('📁 Location: clients/$clientId');
  print('📦 Package: $packageName');
  print('\n🔧 Next steps:');
  print('   1. cd clients/$clientId');
  print('   2. flutter pub get');
  print('   3. Customize assets/ and lib/config.dart');
  print('   4. flutter run');
}

void _updatePubspec(Directory clientDir, String flutterProjectName, String appName) {
  final pubspecFile = File('${clientDir.path}/pubspec.yaml');
  final content = '''
name: $flutterProjectName
description: $appName
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  core_platform:
    path: ../../core_platform
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/
    - assets/images/
    - assets/icons/
''';
  pubspecFile.writeAsStringSync(content);
}

void _createClientConfig(Directory clientDir, String clientId, String appName, String packageName, String projectName) {
  final configFile = File('${clientDir.path}/lib/config.dart');
  final className = _toPascalCase('${projectName}_${clientId}_config');

  configFile.writeAsStringSync('''
import 'package:core_platform/config/base_config.dart';
import 'package:flutter/material.dart';

class $className extends BaseConfig {
  @override
  String get clientId => '$clientId';
  
  @override
  String get appName => '$appName';
  
  @override
  String get packageName => '$packageName';
  
  @override
  String get projectName => '$projectName';
  
  @override
  Color get primaryColor => const Color(0xFF2196F3); // Customize per client
  
  @override
  Color get secondaryColor => const Color(0xFF03DAC6);
  
  @override
  String get apiBaseUrl => 'https://api.example.com/$projectName/$clientId';
  
  @override
  Map<String, dynamic> get firebaseConfig => {
    // Add client-specific Firebase config
    'projectId': '${projectName.replaceAll('_', '-')}-$clientId',
  };
  
  @override
  Map<String, String> get customStrings => {
    // Client-specific text overrides
    'welcome_message': 'Welcome to $appName',
  };
}
''');
}

void _createMainDart(Directory clientDir, String clientId, String projectName) {
  final mainFile = File('${clientDir.path}/lib/main.dart');
  final className = _toPascalCase('${projectName}_${clientId}_config');

  mainFile.writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:core_platform/app.dart';
import 'config.dart';

void main() {
  runApp(WhiteLabelApp(
    config: $className(),
  ));
}
''');
}

void _copyAssets(Directory clientDir) {
  final assetsDir = Directory('${clientDir.path}/assets');
  final imagesDir = Directory('${clientDir.path}/assets/images');
  final iconsDir = Directory('${clientDir.path}/assets/icons');

  assetsDir.createSync();
  imagesDir.createSync();
  iconsDir.createSync();

  // Copy template assets if they exist
  final templateAssets = Directory('client_template/assets');
  if (templateAssets.existsSync()) {
    _copyDirectory(templateAssets, assetsDir);
  }

  // Create README with instructions
  File('${assetsDir.path}/README.md').writeAsStringSync('''
# Client Assets Guide

## Required Files:
- images/logo.png (512x512) - App icon source
- images/splash.png (1080x1920) - Splash screen background  
- images/logo_text.png - Logo with text for splash/login screens

## Optional Files:
- icons/ - Custom icons for navigation/features
- images/onboarding/ - Onboarding screen images
- images/backgrounds/ - Background patterns/images

## Asset Generation:
1. flutter pub get
2. flutter packages pub run flutter_launcher_icons:main
3. dart run flutter_native_splash:create
''');
}

void _copyDirectory(Directory source, Directory destination) {
  destination.createSync(recursive: true);
  source.listSync().forEach((entity) {
    if (entity is File) {
      entity.copySync('${destination.path}/${entity.path.split('/').last}');
    } else if (entity is Directory) {
      _copyDirectory(entity, Directory('${destination.path}/${entity.path.split('/').last}'));
    }
  });
}

String _toPascalCase(String text) {
  return text.split('_').map((word) =>
  word[0].toUpperCase() + word.substring(1).toLowerCase()
  ).join('');
}
#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('client-id', abbr: 'c', help: 'Client identifier (lowercase, underscores)', mandatory: true)
    ..addOption('app-name', abbr: 'n', help: 'Human readable app name', mandatory: true)
    ..addOption('project-name', abbr: 'p', help: 'Base project name (e.g., business_directory, food_delivery)', mandatory: true)
    ..addOption('firebase-account', abbr: 'f', help: 'Firebase account email (required for Firebase projects)')
    ..addOption('org', abbr: 'o', help: 'Organization domain', defaultsTo: 'com.example')
    ..addFlag('web', abbr: 'w', help: 'Include web platform support')
    ..addFlag('skip-firebase', help: 'Skip Firebase project creation and configuration')
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
    final firebaseAccount = results['firebase-account'] as String?;
    final org = results['org'] as String;
    final includeWeb = results['web'] as bool;
    final skipFirebase = results['skip-firebase'] as bool;

    // Validate Firebase account requirement
    if (!skipFirebase && (firebaseAccount == null || firebaseAccount.isEmpty)) {
      print('Error: --firebase-account is required when Firebase is enabled');
      print('Use --skip-firebase if you don\'t want Firebase setup');
      print('Example: dart tools/create_client.dart -c myapp -n "My App" -p restaurant -f example@example.app');
      exit(1);
    }

    // Validate inputs
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(clientId)) {
      print('Error: client-id must be lowercase letters, numbers, and underscores only');
      exit(1);
    }

    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(projectName)) {
      print('Error: project-name must be lowercase letters, numbers, and underscores only');
      exit(1);
    }

    // Validate email format for Firebase account
    if (firebaseAccount != null && !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(firebaseAccount)) {
      print('Error: firebase-account must be a valid email address');
      exit(1);
    }

    await _createClient(clientId, appName, projectName, org, includeWeb, skipFirebase, firebaseAccount);

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
  print('  # Restaurant app (mobile only)');
  print('  dart tools/create_client.dart -c nyc_biz -n "NYC Restaurant" -p restaurant -f admin@example.com');
  print('');
  print('  # Food delivery with web support');
  print('  dart tools/create_client.dart -c chicago_eats -n "Chicago Food Delivery" -p food_delivery -f admin@example.com --web');
  print('');
  print('  # Hotel booking for different organization');
  print('  dart tools/create_client.dart -c miami_hotels -n "Miami Hotels" -p hotel_booking -f admin@company.com');
  print('');
  print('  # Skip Firebase entirely (development)');
  print('  dart tools/create_client.dart -c test_app -n "Test App" -p restaurant --skip-firebase');
  print('');
  print('  # Custom organization with multiple accounts');
  print('  dart tools/create_client.dart -c acme_corp -n "Acme App" -p business -o com.acme -f dev@acme.com --web');
  print('');
  print('Generated package: {org}.{project-name}.{client-id}');
  print('Generated location: clients/{client-id}/');
  print('Firebase project: {project-name}-{client-id}');
}

Future<void> _createClient(String clientId, String appName, String projectName, String org, bool includeWeb, bool skipFirebase, String? firebaseAccount) async {
  final packageName = '$org.$projectName.$clientId';
  final flutterProjectName = '${projectName}_$clientId';
  final apiUrl = 'https://api.example.com/$projectName';
  // Add timestamp to make project ID unique
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8); // Last 5 digits
  final firebaseProjectId = '${projectName.replaceAll('_', '-')}-$clientId-$timestamp';

  print('Creating white-label client...');
  print('├─ Client ID: $clientId');
  print('├─ App Name: $appName');
  print('├─ Project: $projectName');
  print('├─ Package: $packageName');
  print('├─ Include Web: $includeWeb');
  if (skipFirebase) {
    print('├─ Firebase: DISABLED');
  } else {
    print('├─ Firebase: ENABLED (Analytics & Crashlytics)');
    print('├─ Firebase Account: $firebaseAccount');
  }
  print('└─ Flutter Project: $flutterProjectName\n');

  // Ask for user confirmation
  stdout.write('Proceed with client generation? (y/N): ');
  final confirmation = stdin.readLineSync()?.toLowerCase().trim() ?? '';

  if (confirmation != 'y' && confirmation != 'yes') {
    print('Client generation cancelled.');
    exit(0);
  }

  print('');

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

  // 1. Validate Firebase setup FIRST (before creating Flutter project)
  final platforms = includeWeb ? 'android,ios,web' : 'android,ios';
  var firebaseSetupSucceeded = false;

  if (!skipFirebase && firebaseAccount != null) {
    try {
      print('Validating Firebase prerequisites...');
      _checkFirebasePrerequisites(firebaseAccount);

      print('Creating Firebase project: $firebaseProjectId');
      await _createFirebaseProject(firebaseProjectId, appName, firebaseAccount);

      firebaseSetupSucceeded = true;
      print('Firebase project created successfully');
    } catch (e) {
      print('Firebase setup failed: $e');
      print('');
      stdout.write('Continue without Firebase? (y/N): ');
      final continueChoice = stdin.readLineSync()?.toLowerCase().trim() ?? '';

      if (continueChoice != 'y' && continueChoice != 'yes') {
        print('Operation cancelled. Fix Firebase issues and try again.');
        exit(1);
      }

      print('Continuing without Firebase...');
      firebaseSetupSucceeded = false;
    }
  }

  // 2. Create Flutter project (only after Firebase validation)
  print('Creating Flutter project with flutter create...');
  final result = Process.runSync('flutter', [
    'create',
    '--project-name', flutterProjectName,
    '--org', org,
    '--platforms', platforms,
    'clients/$clientId'
  ]);

  if (result.exitCode != 0) {
    print('Flutter create failed:');
    print(result.stderr);
    exit(1);
  }

  print('Flutter project created');

  // 3. Update dependencies and files
  _addDependencies(clientDir);

  // 4. Complete Firebase configuration (if project was created successfully)
  if (!skipFirebase && firebaseSetupSucceeded && firebaseAccount != null) {
    try {
      // Wait a bit for Firebase project to fully propagate
      print('Waiting for Firebase project to propagate...');
      await Future.delayed(Duration(seconds: 5));

      print('Configuring FlutterFire...');
      await _configureFlutterFireWithRetry(clientDir, firebaseProjectId, platforms, firebaseAccount);
      print('Firebase integration completed');
    } catch (e) {
      print('Warning: FlutterFire configuration failed: $e');
      print('Firebase project exists, but client configuration failed.');
      print('Manual configuration required:');
      print('   1. cd clients/$clientId');
      print('   2. flutterfire configure --account=$firebaseAccount --project=$firebaseProjectId --platforms=$platforms');
      _createFirebasePlaceholder(clientDir, firebaseProjectId, firebaseAccount, platforms);
    }
  } else {
    // Create placeholder when Firebase is skipped or failed
    _createFirebasePlaceholder(clientDir, firebaseProjectId, firebaseAccount ?? 'your-firebase-account@example.com', platforms);
  }

  _createClientConfig(clientDir, clientId, appName, packageName, apiUrl);
  _createClientColorScheme(clientDir, clientId);
  _createClientAssetScheme(clientDir, clientId);
  _createMainDart(clientDir, clientId);

  print('\nClient $clientId created successfully!');
  print('Location: clients/$clientId');
  print('Package: $packageName');
  if (!skipFirebase) {
    print('Firebase Project: $firebaseProjectId');
    print('Analytics & Crashlytics: READY');
  }
  print('\nNext steps:');
  print('   1. cd clients/$clientId');
  if (skipFirebase) {
    print('   2. Setup Firebase manually for analytics & crashlytics');
    print('   3. Customize color scheme and assets');
    print('   4. flutter run');
  } else {
    print('   2. Customize color scheme and assets');
    print('   3. flutter run (analytics & crashlytics auto-enabled)');
  }
}

void _addDependencies(Directory clientDir) {
  print('Adding dependencies...');

  // Add core dependencies using flutter pub add
  final addResult = Process.runSync('flutter', [
    'pub', 'add',
    '--directory', clientDir.path,
    'flutter_bloc',
    'equatable',
    'firebase_core',
    'firebase_analytics',
    'firebase_crashlytics'
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
import 'package:firebase_core/firebase_core.dart';
import 'package:core_platform/core/config/config.dart';
import 'client_color_scheme.dart';
import 'client_asset_scheme.dart';
import 'firebase_options.dart';

class $className extends BaseConfig {
  @override
  String get clientId => '$clientId';

  @override
  String get appName => '$appName';

  @override
  String get packageName => '$packageName';

  @override
  String get projectName => '${clientId}'; // Used for project identification

  @override
  String get apiBaseUrl => '$apiUrl';

  @override
  FirebaseOptions get firebaseOptions => DefaultFirebaseOptions.currentPlatform;

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


void _checkFirebasePrerequisites(String requiredAccount) {
  // Check if firebase-tools is installed
  final firebaseResult = Process.runSync('firebase', ['--version']);
  if (firebaseResult.exitCode != 0) {
    throw Exception('Firebase CLI not installed. Run: npm install -g firebase-tools');
  }

  // Check if flutterfire is installed and activated
  print('Checking FlutterFire CLI...');
  final flutterfireResult = Process.runSync('flutterfire', ['--version']);
  if (flutterfireResult.exitCode != 0) {
    print('FlutterFire CLI not found. Activating it...');

    // Automatically activate FlutterFire CLI
    final activateResult = Process.runSync('dart', ['pub', 'global', 'activate', 'flutterfire_cli']);

    if (activateResult.exitCode != 0) {
      throw Exception('Failed to activate FlutterFire CLI: ${activateResult.stderr}');
    }

    print('FlutterFire CLI activated successfully');

    // Verify activation worked
    final verifyResult = Process.runSync('flutterfire', ['--version']);
    if (verifyResult.exitCode != 0) {
      throw Exception('FlutterFire CLI activation failed. Try manually: dart pub global activate flutterfire_cli');
    }
  }

  print('FlutterFire CLI ready');

  // Test Firebase access with the required account
  print('Verifying Firebase access with $requiredAccount...');
  final loginResult = Process.runSync('firebase', ['projects:list', '--account', requiredAccount]);
  if (loginResult.exitCode != 0) {
    print('Error accessing Firebase with account: $requiredAccount');
    print('Firebase CLI output: ${loginResult.stderr}');
    throw Exception('Cannot access Firebase with account $requiredAccount. Ensure account is logged in.');
  }

  print('Firebase access verified for: $requiredAccount');
}


Future<void> _createFirebaseProject(String projectId, String appName, String firebaseAccount) async {
  print('Creating Firebase project: $projectId');
  print('This may take 30-60 seconds...');

  // Start the Firebase project creation process
  final process = Process.start('firebase', [
    'projects:create',
    projectId,
    '--display-name', appName,
    '--account', firebaseAccount,
  ]);

  // Show progress while waiting
  var dots = 0;
  final progressTimer = Timer.periodic(Duration(seconds: 2), (timer) {
    dots = (dots + 1) % 4;
    stdout.write('\rCreating project${'.' * dots}${' ' * (3 - dots)}');
  });

  try {
    final result = await process;
    progressTimer.cancel();
    print('\r' + ' ' * 20 + '\r'); // Clear progress line

    final exitCode = await result.exitCode;

    if (exitCode != 0) {
      final stderr = await result.stderr.transform(utf8.decoder).join();
      print('Firebase CLI Error:');
      print(stderr);
      throw Exception('Firebase project creation failed. See error above.');
    }

    print('Firebase project created: $projectId');
  } catch (e) {
    progressTimer.cancel();
    print('\r' + ' ' * 20 + '\r'); // Clear progress line
    rethrow;
  }
}

Future<void> _configureFlutterFireWithRetry(Directory clientDir, String projectId, String platforms, String firebaseAccount, {int maxRetries = 3}) async {
  print('Configuring FlutterFire...');

  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    final result = Process.runSync('flutterfire', [
      'configure',
      '--project', projectId,
      '--platforms', platforms,
      '--account', firebaseAccount,
      '--yes',
    ], workingDirectory: clientDir.path);

    if (result.exitCode == 0) {
      print('FlutterFire configured');
      return;
    }

    // Check if it's a project not found error
    final errorOutput = result.stderr.toString();
    if (errorOutput.contains('FirebaseProjectNotFoundException') && attempt < maxRetries) {
      print('Firebase project not found yet. Retrying in ${attempt * 5} seconds... (Attempt $attempt/$maxRetries)');
      await Future.delayed(Duration(seconds: attempt * 5));
      continue;
    }

    // If not a retriable error or last attempt, throw
    throw Exception('FlutterFire configuration failed: $errorOutput');
  }
}

void _createFirebasePlaceholder(Directory clientDir, String firebaseProjectId, String firebaseAccount, String platforms) {
  print('Creating Firebase placeholder configuration...');

  final firebaseOptionsFile = File('${clientDir.path}/lib/firebase_options.dart');
  firebaseOptionsFile.writeAsStringSync('''
// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC-placeholder-web-api-key',
    appId: '1:123456789:web:placeholder',
    messagingSenderId: '123456789',
    projectId: '$firebaseProjectId',
    authDomain: '$firebaseProjectId.firebaseapp.com',
    storageBucket: '$firebaseProjectId.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-placeholder-android-api-key',
    appId: '1:123456789:android:placeholder',
    messagingSenderId: '123456789',
    projectId: '$firebaseProjectId',
    storageBucket: '$firebaseProjectId.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC-placeholder-ios-api-key',
    appId: '1:123456789:ios:placeholder',
    messagingSenderId: '123456789',
    projectId: '$firebaseProjectId',
    storageBucket: '$firebaseProjectId.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC-placeholder-macos-api-key',
    appId: '1:123456789:ios:placeholder',
    messagingSenderId: '123456789',
    projectId: '$firebaseProjectId',
    storageBucket: '$firebaseProjectId.appspot.com',
  );
}

// TODO: Replace placeholder values with actual Firebase configuration
// Complete the Firebase setup by running:
// flutterfire configure --account=$firebaseAccount --project=$firebaseProjectId --platforms=$platforms
''');

  print('Firebase placeholder created');
}

String _toPascalCase(String text) {
  return text.split('_').map((word) =>
  word[0].toUpperCase() + word.substring(1).toLowerCase()
  ).join('');
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/config/base_config.dart';
import 'core/cubits/client/client_cubit.dart';

/// Simple main runner for white label architecture
///
/// Usage:
/// ```dart
/// Future<void> main() => MainRunner.run(config: MyClientConfig());
/// ```
class MainRunner {
  /// Run the application with client configuration
  static Future<void> run({required BaseConfig config}) async {
    WidgetsFlutterBinding.ensureInitialized();
    
    runApp(
      BlocProvider(
        create: (context) => ClientCubit(config: config),
        child: const WhiteLabelApp(),
      ),
    );
  }
}
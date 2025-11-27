import 'package:flutter/material.dart';
import 'config/base_config.dart';

class WhiteLabelApp extends StatelessWidget {
  final BaseConfig config;

  const WhiteLabelApp({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appName,
      theme: config.theme,
      home: HomePage(config: config),
    );
  }
}

class HomePage extends StatelessWidget {
  final BaseConfig config;

  const HomePage({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: config.primaryColor,
        foregroundColor: Colors.white,
        title: Text(config.appName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 80,
              color: config.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              config.customStrings['welcome_message'] ??
              'Welcome to ${config.appName}',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Client: ${config.clientId}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Project: ${config.projectName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
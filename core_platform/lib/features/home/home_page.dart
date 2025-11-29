import 'package:flutter/material.dart';

import '../../../core/extensions/client_context_extension.dart';

/// Simple home page demonstrating white label theming
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.clientConfig;
    final colors = config.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(config.appName),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business,
                size: 80,
                color: colors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to ${config.appName}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Client ID: ${config.clientId}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hello from ${config.appName}!'),
                      backgroundColor: colors.primary,
                    ),
                  );
                },
                child: const Text('Test Button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core_platform/core_platform.dart';

/// Simple white label application widget
class WhiteLabelApp extends StatelessWidget {
  const WhiteLabelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientCubit, dynamic>(
      builder: (context, state) {
        final config = context.clientConfig;
        final colors = config.colorScheme;

        return MaterialApp(
          title: config.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: colors.primary,
              primary: colors.primary,
              secondary: colors.secondary,
              background: colors.background,
              surface: colors.surface,
              onSurface: colors.onSurface,
            ),
            scaffoldBackgroundColor: colors.background,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
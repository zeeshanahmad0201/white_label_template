import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core_platform/core_platform.dart';
import 'core/utils/size_utils.dart';

/// Simple white label application widget
class WhiteLabelApp extends StatelessWidget {
  const WhiteLabelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientCubit, dynamic>(
      builder: (context, state) {
        final config = context.clientConfig;
        final colors = config.colorScheme;
        final themeScheme = config.themeScheme;

        final darkTheme = themeScheme.buildDarkTheme(colors);
        final designScheme = config.designScheme;

        return SizerUtils(
          designScheme: designScheme,
          builder: (context, orientation) => MaterialApp(
          title: config.appName,
          debugShowCheckedModeBanner: false,
          theme: themeScheme.buildLightTheme(colors),
          darkTheme: darkTheme, // Only set if client provides dark colors
          themeMode: darkTheme != null ? ThemeMode.system : ThemeMode.light,
            home: const HomePage(),
          ),
        );
      },
    );
  }
}
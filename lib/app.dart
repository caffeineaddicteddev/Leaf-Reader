import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/settings_provider.dart';
import 'ui/router.dart';
import 'ui/theme/app_theme.dart';

class LeafApp extends ConsumerWidget {
  const LeafApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final ThemeMode themeMode = settingsAsync.maybeWhen(
      data: (AppSettings settings) => switch (settings.theme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      orElse: () => ThemeMode.system,
    );

    return MaterialApp.router(
      title: 'Leaf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

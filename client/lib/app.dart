import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/providers/preferences_provider.dart';
import 'core/theme/app_theme.dart';

class OneKeepApp extends ConsumerWidget {
  const OneKeepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final preferences = ref.watch(preferencesProvider);

    return MaterialApp.router(
      title: 'OneKeep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: preferences.themeMode,
      routerConfig: router,
    );
  }
}

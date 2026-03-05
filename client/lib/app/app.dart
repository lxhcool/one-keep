import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class OneKeepApp extends StatelessWidget {
  const OneKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OneKeep',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

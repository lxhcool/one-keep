import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class OneKeepApp extends StatefulWidget {
  const OneKeepApp({super.key});

  @override
  State<OneKeepApp> createState() => _OneKeepAppState();
}

class _OneKeepAppState extends State<OneKeepApp> {
  late final _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OneKeep',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

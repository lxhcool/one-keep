import 'package:flutter/material.dart';

class OneKeepApp extends StatelessWidget {
  const OneKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'OneKeep',
      debugShowCheckedModeBanner: false,
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'onekeep',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

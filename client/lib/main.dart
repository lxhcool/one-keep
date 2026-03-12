import 'package:flutter/material.dart';

void main() {
  runApp(const OneKeepApp());
}

class OneKeepApp extends StatelessWidget {
  const OneKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('OneKeep'),
        ),
      ),
    );
  }
}

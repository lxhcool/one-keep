import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liqing/core/theme/app_theme.dart';

void main() {
  testWidgets('builds a themed scaffold shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: Center(child: Text('OneKeep'))),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('OneKeep'), findsOneWidget);
  });
}

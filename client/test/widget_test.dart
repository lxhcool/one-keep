import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:one_keep/app.dart';

void main() {
  testWidgets('renders base scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OneKeepApp()),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

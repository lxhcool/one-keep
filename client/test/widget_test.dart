import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:one_keep/main.dart';

void main() {
  testWidgets('renders base scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(const OneKeepApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('OneKeep'), findsOneWidget);
  });
}

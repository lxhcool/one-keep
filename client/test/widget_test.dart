import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:one_keep/app/app.dart';

void main() {
  testWidgets('center 记账 label is present and not clickable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OneKeepApp());
    await tester.pumpAndSettle();

    expect(find.text('One Keep'), findsOneWidget);

    await tester.tap(find.text('记账').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('新增流水'), findsNothing);
  });

  testWidgets('+ button opens new transaction page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OneKeepApp());
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tap(find.byKey(const Key('add-button')));
    await tester.pumpAndSettle();

    expect(find.text('新增流水'), findsOneWidget);
  });

  testWidgets('month switch to 2025-05 shows empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OneKeepApp());
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tap(find.byKey(const Key('month-selector')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('2025年 05月'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('本月还没有流水'), findsOneWidget);
  });

  testWidgets('tap record item navigates to detail page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OneKeepApp());
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tap(find.byKey(const ValueKey<String>('record-tx_1')));
    await tester.pumpAndSettle();

    expect(find.text('流水详情'), findsOneWidget);
    expect(find.textContaining('transactionId:'), findsOneWidget);
  });
}

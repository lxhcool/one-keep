import 'package:flutter_test/flutter_test.dart';

import 'package:one_keep/app/app.dart';

void main() {
  testWidgets('renders app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const OneKeepApp());
    await tester.pumpAndSettle();

    expect(find.text('OneKeep 开发中'), findsOneWidget);
  });
}

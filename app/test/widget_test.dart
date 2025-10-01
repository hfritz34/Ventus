import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VentusApp());
    await tester.pumpAndSettle();

    expect(find.text('Ventus'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

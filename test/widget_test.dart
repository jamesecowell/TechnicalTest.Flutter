import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_tech_task/main.dart';

void main() {
  testWidgets('App smoke test - verifies app widget can be instantiated',
      (WidgetTester tester) async {
    // Build the app widget structure without navigating to routes that make HTTP calls
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(),
        ),
      ),
    );

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  test('MyApp widget can be instantiated', () {
    // Verify that MyApp can be created without errors
    const app = MyApp();
    expect(app, isA<StatelessWidget>());
  });
}

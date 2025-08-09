import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mealtime/main.dart';

void main() {
  testWidgets('MealTime app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MealTimeApp());

    // Verify that the app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for the splash screen to appear
    await tester.pump();
    
    // Verify that splash screen content is present
    expect(find.text('MealTime'), findsOneWidget);
    expect(find.text('Smart Meal Planning for Sri Lankan Homes'), findsOneWidget);
  });

  testWidgets('Splash screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MealTimeApp());
    await tester.pump();

    // Check for splash screen elements
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    expect(find.text('MealTime'), findsOneWidget);
  });
}

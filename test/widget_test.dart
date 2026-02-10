// This is a basic Flutter widget test for Analytics Dashboard

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:analytics_dashboard/main.dart';

void main() {
  testWidgets('Analytics Dashboard loads', (WidgetTester tester) async {
    // Load environment variables for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

    // Build our app and trigger a frame
    await tester.pumpWidget(const AnalyticsDashboardApp());

    // Verify that the app title is displayed
    expect(find.text('Analytics Dashboard'), findsOneWidget);
  });
}

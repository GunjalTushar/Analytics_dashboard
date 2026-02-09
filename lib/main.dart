/// 🚀 Analytics Dashboard App
/// 
/// Entry point for the Flutter analytics dashboard

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/analytics_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  runApp(const AnalyticsDashboardApp());
}

class AnalyticsDashboardApp extends StatelessWidget {
  const AnalyticsDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analytics Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AnalyticsDashboardScreen(),
    );
  }
}

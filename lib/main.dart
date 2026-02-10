import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/environment/env_validator.dart';
import 'screens/analytics_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    
    // Validate environment configuration
    final validationResult = EnvValidator.validate();
    
    if (!validationResult.isValid) {
      // Log validation errors
      print(validationResult.errorMessage);
      print('\n${EnvValidator.getConfigSummary()}');
      
      // Run app with error state
      runApp(AnalyticsDashboardApp(
        configError: validationResult.errorMessage,
      ));
      return;
    }
    
    // Log successful configuration
    print('[ENV_CONFIG] ✓ All required environment variables configured');
    print(EnvValidator.getConfigSummary());
    
  } catch (e) {
    print('[ENV_CONFIG_ERROR] Failed to load .env file: $e');
    runApp(AnalyticsDashboardApp(
      configError: 'Failed to load environment configuration: $e',
    ));
    return;
  }
  
  runApp(const AnalyticsDashboardApp());
}

class AnalyticsDashboardApp extends StatelessWidget {
  final String? configError;
  
  const AnalyticsDashboardApp({super.key, this.configError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analytics Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: configError != null
          ? _ConfigurationErrorScreen(error: configError!)
          : const AnalyticsDashboardScreen(),
    );
  }
}

class _ConfigurationErrorScreen extends StatelessWidget {
  final String error;
  
  const _ConfigurationErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Error'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Environment Configuration Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  error,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.red.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Please check your .env file and ensure all required variables are set.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

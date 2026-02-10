/// 📊 Backend Analytics Service
/// Fetches data from your server (works with or without localhost)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analytics_model.dart';

class BackendAnalyticsService {
  // Get server URL from .env, fallback to empty (will throw error if not set)
  static String? get serverUrl => dotenv.env['SERVER_URL'];

  static Future<AnalyticsData> fetchAnalytics() async {
    // Check if SERVER_URL is configured
    if (serverUrl == null || serverUrl!.isEmpty) {
      throw Exception('SERVER_URL not configured');
    }

    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/analytics'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final decoded = json.decode(response.body);

      // Backend returns: { success: true, data: {...} }
      if (decoded['success'] == true && decoded['data'] != null) {
        return AnalyticsData.fromJson(decoded['data']);
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Backend unavailable: $e');
    }
  }
}

/// 📊 Backend Analytics Service
/// Fetches data from your server

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analytics_model.dart';

class BackendAnalyticsService {
  // Connect to your local Python backend server
  static String get serverUrl => 
      dotenv.env['SERVER_URL'] ?? 'http://localhost:3000';

  static Future<AnalyticsData> fetchAnalytics() async {
    try {
      print('🔄 Fetching analytics from: $serverUrl/api/analytics');
      
      final response = await http.get(
        Uri.parse('$serverUrl/api/analytics'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = json.decode(response.body);

      // Backend returns: { success: true, data: {...} }
      if (decoded['success'] == true && decoded['data'] != null) {
        return AnalyticsData.fromJson(decoded['data']);
      }

      throw Exception('Invalid response format: $decoded');
    } catch (e) {
      print('❌ Error fetching analytics: $e');
      throw Exception('Failed to fetch analytics: $e');
    }
  }
}

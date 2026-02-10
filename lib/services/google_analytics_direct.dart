/// ⚠️ DIRECT GOOGLE ANALYTICS ACCESS (NOT RECOMMENDED FOR PRODUCTION)
/// 
/// ✅ SECURITY: All credentials loaded from environment variables
/// For production, use a backend proxy instead.

import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleAnalyticsDirect {
  // ✅ Credentials loaded from .env file
  static String get serviceAccountEmail {
    final email = dotenv.env['GOOGLE_SERVICE_ACCOUNT_EMAIL'];
    if (email == null || email.isEmpty) {
      throw Exception('GOOGLE_SERVICE_ACCOUNT_EMAIL not found in .env file');
    }
    return email;
  }
  
  static String get privateKey {
    final key = dotenv.env['GOOGLE_PRIVATE_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GOOGLE_PRIVATE_KEY not found in .env file');
    }
    return key.replaceAll('\\n', '\n');
  }
  
  static String get propertyId {
    final id = dotenv.env['GA4_PROPERTY_ID'];
    if (id == null || id.isEmpty) {
      throw Exception('GA4_PROPERTY_ID not found in .env file');
    }
    return id;
  }

  /// Fetch analytics data directly from Google Analytics API
  static Future<Map<String, dynamic>> fetchAnalytics() async {
    try {
      // Create service account credentials
      final accountCredentials = auth.ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "client_email": serviceAccountEmail,
        "private_key": privateKey,
      });

      // Get access token
      final scopes = ['https://www.googleapis.com/auth/analytics.readonly'];
      final client = await auth.clientViaServiceAccount(
        accountCredentials,
        scopes,
      );

      // Call Google Analytics Data API
      final response = await client.post(
        Uri.parse(
          'https://analyticsdata.googleapis.com/v1beta/properties/$propertyId:runReport',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "dateRanges": [
            {"startDate": "30daysAgo", "endDate": "today"}
          ],
          "dimensions": [
            {"name": "date"},
            {"name": "country"}
          ],
          "metrics": [
            {"name": "activeUsers"},
            {"name": "sessions"},
            {"name": "screenPageViews"},
            {"name": "engagementRate"}
          ],
        }),
      );

      client.close();

      if (response.statusCode != 200) {
        throw Exception('Google Analytics API error: ${response.statusCode}');
      }

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to fetch from Google Analytics: $e');
    }
  }
}

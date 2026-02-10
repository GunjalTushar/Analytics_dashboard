/// 📊 Direct Google Analytics Access
/// 
/// ✅ Fetches data directly from Google Analytics API (no localhost needed)
/// ✅ All credentials loaded from environment variables

import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analytics_model.dart';

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
  static Future<AnalyticsData> fetchAnalytics() async {
    try {
      // Extract project ID from service account email
      // Format: service-name@project-id.iam.gserviceaccount.com
      final projectId = serviceAccountEmail.split('@')[1].split('.')[0];
      
      // Create service account credentials with all required fields
      final accountCredentials = auth.ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": projectId,
        "private_key_id": "dummy", // Not required for authentication
        "private_key": privateKey,
        "client_email": serviceAccountEmail,
        "client_id": "dummy", // Not required for authentication
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/${Uri.encodeComponent(serviceAccountEmail)}"
      });

      // Get access token
      final scopes = ['https://www.googleapis.com/auth/analytics.readonly'];
      final client = await auth.clientViaServiceAccount(
        accountCredentials,
        scopes,
      );

      // Fetch overview data (totals)
      final overviewResponse = await client.post(
        Uri.parse(
          'https://analyticsdata.googleapis.com/v1beta/properties/$propertyId:runReport',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "dateRanges": [{"startDate": "30daysAgo", "endDate": "today"}],
          "metrics": [
            {"name": "activeUsers"},
            {"name": "sessions"},
            {"name": "screenPageViews"},
            {"name": "engagementRate"}
          ],
        }),
      );

      // Fetch daily users data
      final dailyResponse = await client.post(
        Uri.parse(
          'https://analyticsdata.googleapis.com/v1beta/properties/$propertyId:runReport',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "dateRanges": [{"startDate": "30daysAgo", "endDate": "today"}],
          "dimensions": [{"name": "date"}],
          "metrics": [{"name": "activeUsers"}],
        }),
      );

      // Fetch country data
      final countryResponse = await client.post(
        Uri.parse(
          'https://analyticsdata.googleapis.com/v1beta/properties/$propertyId:runReport',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "dateRanges": [{"startDate": "30daysAgo", "endDate": "today"}],
          "dimensions": [{"name": "country"}],
          "metrics": [{"name": "activeUsers"}],
        }),
      );

      client.close();

      // Check responses
      if (overviewResponse.statusCode != 200) {
        throw Exception('Overview API error: ${overviewResponse.statusCode}');
      }
      if (dailyResponse.statusCode != 200) {
        throw Exception('Daily API error: ${dailyResponse.statusCode}');
      }
      if (countryResponse.statusCode != 200) {
        throw Exception('Country API error: ${countryResponse.statusCode}');
      }

      // Parse responses
      final overviewData = json.decode(overviewResponse.body);
      final dailyData = json.decode(dailyResponse.body);
      final countryData = json.decode(countryResponse.body);

      // Format the data
      return _formatAnalyticsData(overviewData, dailyData, countryData);
    } catch (e) {
      throw Exception('Failed to fetch from Google Analytics: $e');
    }
  }

  static AnalyticsData _formatAnalyticsData(
    Map<String, dynamic> overviewData,
    Map<String, dynamic> dailyData,
    Map<String, dynamic> countryData,
  ) {
    // Parse overview
    final overviewRows = overviewData['rows'] as List?;
    String activeUsers = '0';
    String sessions = '0';
    String screenPageViews = '0';
    String engagementRate = '0%';

    if (overviewRows != null && overviewRows.isNotEmpty) {
      final row = overviewRows[0];
      final metrics = row['metricValues'] as List;
      activeUsers = metrics[0]['value'] ?? '0';
      sessions = metrics[1]['value'] ?? '0';
      screenPageViews = metrics[2]['value'] ?? '0';
      final engagement = double.tryParse(metrics[3]['value'] ?? '0') ?? 0;
      engagementRate = '${(engagement * 100).toStringAsFixed(1)}%';
    }

    // Parse daily users
    final dailyRows = dailyData['rows'] as List? ?? [];
    final dailyUsers = dailyRows.map((row) {
      final date = row['dimensionValues'][0]['value'];
      final users = int.tryParse(row['metricValues'][0]['value'] ?? '0') ?? 0;
      return DailyUsers(date: date, users: users);
    }).toList();

    dailyUsers.sort((a, b) => a.date.compareTo(b.date));

    // Parse top countries
    final countryRows = countryData['rows'] as List? ?? [];
    final topCountries = countryRows.map((row) {
      final country = row['dimensionValues'][0]['value'];
      final users = int.tryParse(row['metricValues'][0]['value'] ?? '0') ?? 0;
      return TopCountry(country: country, users: users);
    }).toList();

    topCountries.sort((a, b) => b.users.compareTo(a.users));

    return AnalyticsData(
      overview: Overview(
        activeUsers: activeUsers,
        sessions: sessions,
        screenPageViews: screenPageViews,
        engagementRate: engagementRate,
      ),
      dailyUsers: dailyUsers,
      topCountries: topCountries.take(10).toList(),
    );
  }
}

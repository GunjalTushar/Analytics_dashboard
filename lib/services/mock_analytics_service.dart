/// 🧪 Mock Analytics Service
/// 
/// Use this temporarily to test the UI while setting up Supabase Edge Function

import '../models/analytics_model.dart';

class MockAnalyticsService {
  static Future<AnalyticsData> fetchAnalytics() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return AnalyticsData(
      overview: Overview(
        activeUsers: "1,234",
        sessions: "5,678",
        screenPageViews: "12,345",
        engagementRate: "67.8%",
      ),
      dailyUsers: [
        DailyUsers(date: "2024-01-01", users: 100),
        DailyUsers(date: "2024-01-02", users: 150),
        DailyUsers(date: "2024-01-03", users: 120),
        DailyUsers(date: "2024-01-04", users: 180),
        DailyUsers(date: "2024-01-05", users: 200),
        DailyUsers(date: "2024-01-06", users: 170),
        DailyUsers(date: "2024-01-07", users: 190),
        DailyUsers(date: "2024-01-08", users: 210),
        DailyUsers(date: "2024-01-09", users: 195),
        DailyUsers(date: "2024-01-10", users: 220),
      ],
      topCountries: [
        TopCountry(country: "USA", users: 500),
        TopCountry(country: "UK", users: 300),
        TopCountry(country: "Canada", users: 200),
        TopCountry(country: "Germany", users: 150),
        TopCountry(country: "France", users: 100),
        TopCountry(country: "Japan", users: 80),
        TopCountry(country: "Australia", users: 70),
      ],
    );
  }
}

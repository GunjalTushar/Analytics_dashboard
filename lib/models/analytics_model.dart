/// 📊 Analytics Data Models
/// 
/// These models match your React dashboard API contract

class AnalyticsData {
  final Overview overview;
  final List<DailyUsers> dailyUsers;
  final List<TopCountry> topCountries;

  AnalyticsData({
    required this.overview,
    required this.dailyUsers,
    required this.topCountries,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      overview: Overview.fromJson(json['overview']),
      dailyUsers: (json['dailyUsers'] as List)
          .map((e) => DailyUsers.fromJson(e))
          .toList(),
      topCountries: (json['topCountries'] as List)
          .map((e) => TopCountry.fromJson(e))
          .toList(),
    );
  }
}

class Overview {
  final String activeUsers;
  final String sessions;
  final String screenPageViews;
  final String engagementRate;

  Overview({
    required this.activeUsers,
    required this.sessions,
    required this.screenPageViews,
    required this.engagementRate,
  });

  factory Overview.fromJson(Map<String, dynamic> json) {
    return Overview(
      activeUsers: json['activeUsers'],
      sessions: json['sessions'],
      screenPageViews: json['screenPageViews'],
      engagementRate: json['engagementRate'],
    );
  }
}

class DailyUsers {
  final String date;
  final int users;

  DailyUsers({required this.date, required this.users});

  factory DailyUsers.fromJson(Map<String, dynamic> json) {
    return DailyUsers(
      date: json['date'],
      users: json['users'],
    );
  }
}

class TopCountry {
  final String country;
  final int users;

  TopCountry({required this.country, required this.users});

  factory TopCountry.fromJson(Map<String, dynamic> json) {
    return TopCountry(
      country: json['country'],
      users: json['users'],
    );
  }
}

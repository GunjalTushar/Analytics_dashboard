# 📊 Flutter Analytics Dashboard

A fully functional Flutter analytics dashboard that mirrors your React dashboard with Google Analytics integration.

## ✨ Features

✅ **Overview Cards** - Active Users, Sessions, Page Views, Engagement Rate  
✅ **Line Chart** - Daily user activity with date labels  
✅ **Bar Chart** - Top countries by users  
✅ **Pull-to-Refresh** - Swipe down to reload data  
✅ **Error Handling** - Retry mechanism with clear error messages  
✅ **Loading States** - Smooth loading indicators  
✅ **Responsive Layout** - Works on all screen sizes  
✅ **Same API Contract** - Compatible with your React backend  

## 🚀 Quick Start

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Supabase

Open `lib/config/api_config.dart` and add your Supabase credentials:

```dart
static const String supabaseUrl = "https://YOUR_PROJECT.supabase.co";
static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";
```

📖 See `SUPABASE_SETUP.md` for detailed setup instructions

### 3. Run the App

```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── config/
│   └── api_config.dart          # 🔑 Supabase configuration (ADD YOUR CREDENTIALS HERE)
├── models/
│   └── analytics_model.dart     # 📊 Data models
├── services/
│   └── analytics_service.dart   # 🌐 API service
├── screens/
│   └── analytics_dashboard_screen.dart  # 🎨 Main dashboard UI
└── main.dart                    # 🚀 App entry point

SUPABASE_SETUP.md                # 📖 Detailed Supabase setup guide
```

## 🔧 Supabase Edge Function

The app calls your Supabase Edge Function which should return data in this format:

```json
{
  "success": true,
  "data": {
    "overview": {
      "activeUsers": "1,234",
      "sessions": "5,678",
      "screenPageViews": "12,345",
      "engagementRate": "67.8%"
    },
    "dailyUsers": [
      { "date": "2024-01-01", "users": 100 },
      { "date": "2024-01-02", "users": 150 }
    ],
    "topCountries": [
      { "country": "USA", "users": 500 },
      { "country": "UK", "users": 300 }
    ]
  }
}
```

## 🎨 Customization

### Change Colors

Edit the theme in `lib/main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
),
```

### Modify Chart Styles

Charts are in `lib/screens/analytics_dashboard_screen.dart`:
- Line chart: `_userActivityChart()` method
- Bar chart: `_countryChart()` method

## 📦 Dependencies

- `fl_chart: ^0.68.0` - Beautiful charts
- `http: ^1.2.0` - HTTP requests

## 🔐 Authentication

The app automatically includes Supabase authentication headers:

```dart
static Map<String, String> get headers => {
  'Content-Type': 'application/json',
  'apikey': supabaseAnonKey,
  'Authorization': 'Bearer $supabaseAnonKey',
};
```

This matches your React web app's authentication approach.

## 🐛 Troubleshooting

### "Failed to load analytics"

1. Check Supabase URL and Anon Key in `lib/config/api_config.dart`
2. Verify your Edge Function is deployed: `supabase functions list`
3. Test Edge Function directly with curl (see `SUPABASE_SETUP.md`)
4. Check Edge Function logs in Supabase dashboard
5. Verify the API response format matches the expected structure

### Charts not displaying

1. Verify your API returns valid data
2. Check that `dailyUsers` and `topCountries` arrays are not empty
3. Ensure numeric values are valid integers

## 🚀 Next Steps

For production-ready architecture, consider:

1. **State Management** - Add Cubit/Bloc for better state handling
2. **Repository Pattern** - Separate data layer from UI
3. **Caching** - Store data locally for offline access
4. **Error Logging** - Add Sentry or Firebase Crashlytics
5. **Testing** - Add unit and widget tests

## 📝 License

MIT License - Feel free to use in your projects!

# 📱 Analytics Dashboard Integration Guide

## Overview

This analytics dashboard is a **self-contained, production-ready** Flutter screen that can be integrated into any existing Flutter application. It works with or without a backend server.

---

## ✨ Features

- ✅ **Self-contained** - No dependencies on localhost
- ✅ **Graceful fallback** - Uses mock data if backend unavailable
- ✅ **Production-ready** - All credentials from environment variables
- ✅ **Responsive design** - Works on all screen sizes
- ✅ **Pull-to-refresh** - Easy data updates
- ✅ **Professional charts** - Line and bar charts with fl_chart
- ✅ **Zero configuration** - Works out of the box with demo data

---

## 🚀 Quick Integration (3 Steps)

### 1. Copy Required Files

Copy these files to your main project:

```
lib/screens/analytics_dashboard_screen.dart
lib/models/analytics_model.dart
lib/services/backend_analytics_service.dart
lib/services/mock_analytics_service.dart
```

### 2. Add Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  fl_chart: ^0.69.2
  http: ^1.2.0
  flutter_dotenv: ^5.1.0
```

### 3. Navigate to the Screen

From anywhere in your app:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AnalyticsDashboardScreen(),
  ),
);
```

**That's it!** The dashboard will work with demo data immediately.

---

## 🔧 Configuration Options

### Option 1: Use Demo Data (Default)

No configuration needed. The dashboard automatically uses mock data if no backend is configured.

### Option 2: Connect to Your Backend

1. Create `.env` file in your project root:

```bash
# Optional: Your analytics backend URL
SERVER_URL=https://your-api-url.com

# Optional: Supabase credentials (if using Supabase)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

2. Add `.env` to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

3. Load environment variables in `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (optional)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found - will use demo data
  }
  
  runApp(const YourApp());
}
```

---

## 📊 Backend API Contract

If you want to connect to a real backend, your API should return:

**Endpoint**: `GET /api/analytics`

**Response Format**:

```json
{
  "success": true,
  "data": {
    "overview": {
      "activeUsers": "4726",
      "sessions": "10138",
      "screenPageViews": "71756",
      "engagementRate": "66.3%"
    },
    "dailyUsers": [
      {"date": "20260110", "users": 157},
      {"date": "20260111", "users": 97}
    ],
    "topCountries": [
      {"country": "India", "users": 2847},
      {"country": "United States", "users": 1234}
    ]
  }
}
```

---

## 🎨 Customization

### Change Colors

Edit `analytics_dashboard_screen.dart`:

```dart
// Overview card colors
_card("👤 Active Users", data!.overview.activeUsers, Colors.blue),
_card("📊 Sessions", data!.overview.sessions, Colors.green),
_card("📄 Page Views", data!.overview.screenPageViews, Colors.orange),
_card("💡 Engagement", data!.overview.engagementRate, Colors.purple),
```

### Change App Bar

```dart
AppBar(
  title: const Text("Your Custom Title"),
  backgroundColor: Colors.yourColor,
)
```

### Modify Chart Heights

```dart
SizedBox(
  height: 360, // Change this value
  child: LineChart(...),
)
```

---

## 🔒 Security

### Environment Variables

All sensitive data should be in `.env`:

```bash
# Add .env to .gitignore
echo ".env" >> .gitignore

# Verify it's ignored
git check-ignore .env
```

### Production Deployment

For production, use:
- **Environment variables** from your CI/CD
- **Secrets management** (AWS Secrets Manager, etc.)
- **Backend proxy** instead of direct API calls

---

## 🧪 Testing

The dashboard includes automatic fallback:

1. **With Backend**: Shows real data
2. **Without Backend**: Shows demo data with "Demo Data" badge
3. **On Error**: Shows error screen with retry button

Test all scenarios:

```dart
// Test with backend
SERVER_URL=https://your-api.com flutter run

// Test without backend (demo mode)
flutter run

// Test error handling
SERVER_URL=https://invalid-url.com flutter run
```

---

## 📱 Integration Examples

### Example 1: Add to Drawer

```dart
Drawer(
  child: ListView(
    children: [
      ListTile(
        leading: const Icon(Icons.analytics),
        title: const Text('Analytics'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnalyticsDashboardScreen(),
            ),
          );
        },
      ),
    ],
  ),
)
```

### Example 2: Add to Bottom Navigation

```dart
BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
  ],
  onTap: (index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AnalyticsDashboardScreen(),
        ),
      );
    }
  },
)
```

### Example 3: Add as Tab

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      bottom: const TabBar(
        tabs: [
          Tab(text: 'Home'),
          Tab(text: 'Analytics'),
          Tab(text: 'Settings'),
        ],
      ),
    ),
    body: const TabBarView(
      children: [
        HomeScreen(),
        AnalyticsDashboardScreen(),
        SettingsScreen(),
      ],
    ),
  ),
)
```

---

## 🐛 Troubleshooting

### Issue: "SERVER_URL not configured"

**Solution**: Either:
1. Add `SERVER_URL` to `.env` file, OR
2. Remove the check to always use demo data

### Issue: Charts not displaying

**Solution**: Make sure `fl_chart` is added to `pubspec.yaml`:

```bash
flutter pub add fl_chart
```

### Issue: Environment variables not loading

**Solution**: 
1. Check `.env` is in project root
2. Add `.env` to `pubspec.yaml` assets
3. Load in `main.dart` before `runApp()`

### Issue: "Demo Data" badge always showing

**Solution**: 
1. Verify `SERVER_URL` is set in `.env`
2. Check backend is running and accessible
3. Test backend URL in browser/Postman

---

## 📚 File Structure

```
your_project/
├── lib/
│   ├── screens/
│   │   └── analytics_dashboard_screen.dart  ← Main screen
│   ├── models/
│   │   └── analytics_model.dart              ← Data models
│   └── services/
│       ├── backend_analytics_service.dart    ← Real data
│       └── mock_analytics_service.dart       ← Demo data
├── .env                                       ← Configuration (optional)
└── pubspec.yaml                               ← Dependencies
```

---

## ✅ Checklist

Before merging to your main project:

- [ ] Copy all required files
- [ ] Add dependencies to `pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Test with demo data (no .env)
- [ ] Test with backend (with .env)
- [ ] Test error handling (invalid URL)
- [ ] Verify `.env` is in `.gitignore`
- [ ] Test on different screen sizes
- [ ] Test pull-to-refresh
- [ ] Test navigation integration

---

## 🎯 Production Checklist

- [ ] Remove debug prints
- [ ] Add error tracking (Sentry, Firebase Crashlytics)
- [ ] Add analytics tracking
- [ ] Implement proper authentication
- [ ] Use HTTPS for all API calls
- [ ] Add rate limiting
- [ ] Implement caching
- [ ] Add loading skeletons
- [ ] Test on real devices
- [ ] Performance testing

---

## 📞 Support

If you encounter issues:

1. Check this guide first
2. Verify all files are copied correctly
3. Check dependencies are installed
4. Test with demo data first
5. Then test with backend

---

**Last Updated**: February 9, 2026  
**Version**: 1.0.0  
**Status**: Production Ready ✅

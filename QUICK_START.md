# 🚀 Quick Start Guide

## ✅ Current Status

Your Flutter Analytics Dashboard is set up and running with:
- ✅ Supabase configuration loaded from `.env`
- ✅ Mock data displaying in the app
- ✅ All sensitive data secured in `.env` file
- ✅ `.env` excluded from version control

## 📋 What You Have

### Files Created:
1. **`.env`** - Your actual credentials (Supabase already configured)
2. **`.env.example`** - Template for team members
3. **`ENV_SETUP_GUIDE.md`** - Complete documentation
4. **`ENV_MIGRATION_COMPLETE.md`** - Migration details

### App Features:
- 📊 Overview cards (Active Users, Sessions, Page Views, Engagement)
- 📈 Line chart showing daily user activity
- 🌍 Bar chart showing top countries
- 🔄 Pull-to-refresh functionality
- ⚠️ Orange banner indicating mock data mode

## 🎯 Next Steps to Get Real Data

### Step 1: Add Google Analytics Credentials to .env

Open `.env` and add these three values:

```bash
GOOGLE_SERVICE_ACCOUNT_EMAIL=your-service-account@project.iam.gserviceaccount.com
GOOGLE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nYOUR_KEY\n-----END PRIVATE KEY-----
GA4_PROPERTY_ID=123456789
```

**Where to get these:**
- Service Account Email: [Google Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts)
- Private Key: Download JSON key from service account
- GA4 Property ID: Google Analytics → Admin → Property Settings

### Step 2: Set Supabase Edge Function Secrets

```bash
# Install Supabase CLI (if not installed)
brew install supabase/tap/supabase

# Login
supabase login

# Link your project
supabase link --project-ref gdkwidkzbdwjtzgjezch

# Set secrets
supabase secrets set GOOGLE_SERVICE_ACCOUNT_EMAIL="your-email"
supabase secrets set GOOGLE_PRIVATE_KEY="your-key"
supabase secrets set GA4_PROPERTY_ID="123456789"
```

### Step 3: Create and Deploy Edge Function

```bash
# Create function
supabase functions new analytics

# Copy code from supabase_edge_function_example.ts
# to supabase/functions/analytics/index.ts

# Deploy
supabase functions deploy analytics
```

### Step 4: Switch to Real API

In `lib/screens/analytics_dashboard_screen.dart`, change line ~35:

```dart
// FROM:
final result = await MockAnalyticsService.fetchAnalytics();

// TO:
final result = await AnalyticsService.fetchAnalytics();
```

### Step 5: Remove Mock Data Banner

In `lib/screens/analytics_dashboard_screen.dart`, remove the orange banner section (lines ~60-75).

### Step 6: Restart App

```bash
flutter run
```

## 🧪 Quick Test (Current Setup)

The app is currently running with mock data. You should see:

1. **Orange Banner** at the top saying "Using mock data..."
2. **Overview Cards:**
   - Active Users: 1,234
   - Sessions: 5,678
   - Page Views: 12,345
   - Engagement: 67.8%
3. **Line Chart** with 10 days of sample data
4. **Bar Chart** with 7 countries

## 📁 Project Structure

```
.
├── .env                              # 🔐 Your secrets
├── .env.example                      # 📝 Template
├── ENV_SETUP_GUIDE.md               # 📖 Detailed guide
├── QUICK_START.md                   # 📄 This file
├── lib/
│   ├── main.dart                    # Loads .env
│   ├── config/
│   │   └── api_config.dart          # Reads from .env
│   ├── models/
│   │   └── analytics_model.dart     # Data models
│   ├── services/
│   │   ├── analytics_service.dart   # Real API service
│   │   └── mock_analytics_service.dart  # Mock data
│   └── screens/
│       └── analytics_dashboard_screen.dart  # Main UI
└── supabase_edge_function_example.ts  # Edge Function code
```

## 🔐 Security Checklist

- [x] `.env` file created
- [x] `.env` in `.gitignore`
- [x] No hardcoded credentials in code
- [x] Supabase credentials in `.env`
- [ ] Google Analytics credentials in `.env`
- [ ] Supabase secrets set
- [ ] Edge Function deployed

## 📚 Documentation

| File | Purpose |
|------|---------|
| `ENV_SETUP_GUIDE.md` | Complete environment setup |
| `ENV_MIGRATION_COMPLETE.md` | What changed and why |
| `SUPABASE_SETUP.md` | Supabase-specific setup |
| `DEPLOY_EDGE_FUNCTION.md` | Edge Function deployment |
| `ERROR_FIXED.md` | Previous error resolution |
| `README.md` | General project info |

## 🐛 Troubleshooting

### App shows error screen

**Check:**
1. Is the app running? Look for "Flutter run key commands" in terminal
2. Did you restart after changing `.env`?
3. Run: `flutter clean && flutter pub get && flutter run`

### Can't find .env file

**Location:** Project root directory (same level as `pubspec.yaml`)

```bash
# Check if it exists
ls -la .env

# If not, it should have been created. Create it:
cp .env.example .env
```

### Values from .env not loading

**Fix:**
1. Verify `.env` is in `pubspec.yaml` assets
2. Run `flutter pub get`
3. Completely restart the app (not hot reload)

## 🎉 You're All Set!

Your app is running with:
- ✅ Secure environment variable management
- ✅ Mock data for testing
- ✅ Ready to connect to real Google Analytics

Just add your Google credentials and deploy the Edge Function to see real data!

## 💡 Tips

1. **Development:** Keep using mock data while building features
2. **Testing:** Deploy Edge Function to staging environment first
3. **Production:** Use separate `.env.production` with production credentials
4. **Team:** Share `.env.example`, never share `.env`

## 🆘 Need Help?

- Check `ENV_SETUP_GUIDE.md` for detailed instructions
- Review `DEPLOY_EDGE_FUNCTION.md` for Edge Function setup
- See `supabase_edge_function_example.ts` for complete code example

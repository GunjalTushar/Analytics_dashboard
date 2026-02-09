# 🔐 Environment Variables - Complete Summary

## 📊 All Sensitive Data Locations

### 1. Flutter App (.env file)

**Location:** `.env` in project root

**Variables:**
```bash
# ✅ Already Configured
SUPABASE_URL=https://gdkwidkzbdwjtzgjezch.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# ⚠️ You Need to Add
GOOGLE_SERVICE_ACCOUNT_EMAIL=your-email@project.iam.gserviceaccount.com
GOOGLE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----
GA4_PROPERTY_ID=123456789

# 🔧 Optional
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
DATABASE_URL=postgresql://postgres:password@db.project.supabase.co:5432/postgres
```

**Purpose:**
- Supabase credentials for API calls
- Reference for Google credentials (not used in Flutter app directly)

**Security:** 
- ✅ In `.gitignore`
- ✅ Never committed to git
- ✅ Loaded at app startup

---

### 2. Supabase Edge Function (Supabase Secrets)

**Set via CLI:**
```bash
supabase secrets set GOOGLE_SERVICE_ACCOUNT_EMAIL="your-email"
supabase secrets set GOOGLE_PRIVATE_KEY="your-key"
supabase secrets set GA4_PROPERTY_ID="123456789"
```

**Purpose:**
- Server-side authentication with Google Analytics API
- Secure storage in Supabase infrastructure

**Security:**
- ✅ Stored encrypted in Supabase
- ✅ Never exposed to client
- ✅ Only accessible by Edge Function

---

## 🔄 Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App                            │
│                                                             │
│  📄 .env file                                               │
│  ┌──────────────────────────────────────────────┐          │
│  │ SUPABASE_URL                                 │          │
│  │ SUPABASE_ANON_KEY                            │          │
│  └──────────────────────────────────────────────┘          │
│                        ↓                                    │
│  📱 lib/config/api_config.dart                              │
│  ┌──────────────────────────────────────────────┐          │
│  │ dotenv.env['SUPABASE_URL']                   │          │
│  │ dotenv.env['SUPABASE_ANON_KEY']              │          │
│  └──────────────────────────────────────────────┘          │
│                        ↓                                    │
│  🌐 lib/services/analytics_service.dart                     │
│  ┌──────────────────────────────────────────────┐          │
│  │ Makes HTTP request with headers:             │          │
│  │ - apikey: SUPABASE_ANON_KEY                  │          │
│  │ - Authorization: Bearer SUPABASE_ANON_KEY    │          │
│  └──────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
                        │
                        │ HTTPS Request
                        ↓
┌─────────────────────────────────────────────────────────────┐
│              Supabase Edge Function                         │
│                                                             │
│  🔐 Supabase Secrets (set via CLI)                          │
│  ┌──────────────────────────────────────────────┐          │
│  │ GOOGLE_SERVICE_ACCOUNT_EMAIL                 │          │
│  │ GOOGLE_PRIVATE_KEY                           │          │
│  │ GA4_PROPERTY_ID                              │          │
│  └──────────────────────────────────────────────┘          │
│                        ↓                                    │
│  📊 Edge Function Code                                      │
│  ┌──────────────────────────────────────────────┐          │
│  │ 1. Get secrets from Deno.env                 │          │
│  │ 2. Create JWT with private key               │          │
│  │ 3. Exchange JWT for access token             │          │
│  │ 4. Call Google Analytics API                 │          │
│  │ 5. Format and return data                    │          │
│  └──────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
                        │
                        │ OAuth 2.0 + JWT
                        ↓
┌─────────────────────────────────────────────────────────────┐
│           Google Analytics Data API                         │
│                                                             │
│  Returns analytics data for your GA4 property              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Variable Reference

| Variable | Where Stored | Used By | Required | Public? |
|----------|--------------|---------|----------|---------|
| `SUPABASE_URL` | `.env` | Flutter App | ✅ Yes | ✅ Yes (public) |
| `SUPABASE_ANON_KEY` | `.env` | Flutter App | ✅ Yes | ✅ Yes (public) |
| `GOOGLE_SERVICE_ACCOUNT_EMAIL` | Supabase Secrets | Edge Function | ✅ Yes | ❌ No (private) |
| `GOOGLE_PRIVATE_KEY` | Supabase Secrets | Edge Function | ✅ Yes | ❌ No (private) |
| `GA4_PROPERTY_ID` | Supabase Secrets | Edge Function | ✅ Yes | ❌ No (private) |
| `SUPABASE_SERVICE_ROLE_KEY` | `.env` | Optional | ❌ No | ❌ No (private) |
| `DATABASE_URL` | `.env` | Optional | ❌ No | ❌ No (private) |

---

## 🎯 Setup Checklist

### Flutter App Setup
- [x] `.env` file created
- [x] `SUPABASE_URL` added
- [x] `SUPABASE_ANON_KEY` added
- [ ] `GOOGLE_SERVICE_ACCOUNT_EMAIL` added (reference only)
- [ ] `GOOGLE_PRIVATE_KEY` added (reference only)
- [ ] `GA4_PROPERTY_ID` added (reference only)
- [x] `.env` in `.gitignore`
- [x] `flutter_dotenv` package installed
- [x] `.env` in `pubspec.yaml` assets
- [x] `dotenv.load()` in `main.dart`

### Supabase Edge Function Setup
- [ ] Supabase CLI installed
- [ ] Logged in to Supabase
- [ ] Project linked
- [ ] `GOOGLE_SERVICE_ACCOUNT_EMAIL` secret set
- [ ] `GOOGLE_PRIVATE_KEY` secret set
- [ ] `GA4_PROPERTY_ID` secret set
- [ ] Edge Function created
- [ ] Edge Function code added
- [ ] Edge Function deployed

---

## 🔒 Security Best Practices

### ✅ DO:

1. **Keep `.env` local only**
   ```bash
   # Check it's in .gitignore
   git check-ignore .env
   # Should output: .env
   ```

2. **Use `.env.example` for team**
   ```bash
   # Team members copy and fill in their values
   cp .env.example .env
   ```

3. **Rotate keys regularly**
   - Change keys every 90 days
   - Immediately if compromised

4. **Use different keys per environment**
   ```bash
   .env.development
   .env.staging
   .env.production
   ```

5. **Set Supabase secrets via CLI only**
   ```bash
   # Never hardcode in Edge Function
   supabase secrets set KEY="value"
   ```

### ❌ DON'T:

1. **Never commit `.env`**
   ```bash
   # If accidentally committed:
   git rm --cached .env
   git commit -m "Remove .env"
   # Then rotate all keys!
   ```

2. **Never share `.env` via email/chat**
   - Use secure password managers
   - Or share via encrypted channels

3. **Never log sensitive values**
   ```dart
   // ❌ Bad
   print('API Key: ${ApiConfig.supabaseAnonKey}');
   
   // ✅ Good
   print('API Key configured: ${ApiConfig.supabaseAnonKey.isNotEmpty}');
   ```

4. **Never use production keys in development**
   - Always use separate credentials

---

## 🧪 Testing Your Setup

### Test 1: Check .env is loaded

Add to `main.dart` temporarily:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  
  print('✅ .env loaded');
  print('Supabase URL: ${dotenv.env['SUPABASE_URL']}');
  print('Has Anon Key: ${dotenv.env['SUPABASE_ANON_KEY']?.isNotEmpty}');
  
  runApp(const AnalyticsDashboardApp());
}
```

### Test 2: Verify API Config

Add to your dashboard temporarily:
```dart
import 'package:your_app/config/api_config.dart';

@override
void initState() {
  super.initState();
  print('API URL: ${ApiConfig.analyticsUrl}');
  print('Has Auth: ${ApiConfig.supabaseAnonKey.isNotEmpty}');
  fetchData();
}
```

### Test 3: Check Supabase Secrets

```bash
# List all secrets
supabase secrets list

# Should show:
# - GOOGLE_SERVICE_ACCOUNT_EMAIL
# - GOOGLE_PRIVATE_KEY
# - GA4_PROPERTY_ID
```

---

## 📝 Quick Reference Commands

```bash
# Flutter App
flutter pub get                    # Install dependencies
flutter clean                      # Clean build
flutter run                        # Run app

# Supabase
supabase login                     # Login to Supabase
supabase link --project-ref XXX    # Link project
supabase secrets set KEY="value"   # Set secret
supabase secrets list              # List secrets
supabase functions deploy NAME     # Deploy function
supabase functions logs NAME       # View logs

# Git
git status                         # Check what's tracked
git check-ignore .env              # Verify .env is ignored
```

---

## 🎉 Summary

Your environment variables are now properly configured:

1. ✅ **Flutter App** reads from `.env` file
2. ✅ **Edge Function** reads from Supabase Secrets
3. ✅ **No hardcoded credentials** in source code
4. ✅ **Git-safe** (`.env` excluded)
5. ✅ **Team-friendly** (`.env.example` template)

Just add your Google Analytics credentials and deploy the Edge Function to complete the setup!

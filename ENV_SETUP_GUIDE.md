# 🔐 Environment Variables Setup Guide

## 📋 Overview

All sensitive information is now stored in the `.env` file, which is:
- ✅ Excluded from version control (in `.gitignore`)
- ✅ Loaded at app startup
- ✅ Accessed securely through `ApiConfig` class

## 🚀 Quick Setup

### Step 1: Your .env File is Already Created

The `.env` file has been created with your Supabase credentials. You need to add:

1. **Google Service Account Email**
2. **Google Private Key**
3. **GA4 Property ID**

### Step 2: Get Your Google Analytics Credentials

#### A. Service Account Email

1. Go to [Google Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts)
2. Select your project
3. Find your service account
4. Copy the email (format: `name@project.iam.gserviceaccount.com`)

#### B. Private Key

1. In the same service account page
2. Click on the service account
3. Go to "Keys" tab
4. Click "Add Key" → "Create new key"
5. Choose JSON format
6. Download the file
7. Open the JSON file and copy the `private_key` value

**Important:** The key should include `\n` for line breaks:
```
-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0B...\n-----END PRIVATE KEY-----
```

#### C. GA4 Property ID

1. Go to [Google Analytics](https://analytics.google.com/)
2. Select your property
3. Go to Admin → Property Settings
4. Copy the Property ID (numeric value like `123456789`)

### Step 3: Update Your .env File

Open `.env` and replace these values:

```bash
# Replace with your actual values
GOOGLE_SERVICE_ACCOUNT_EMAIL=your-actual-email@project.iam.gserviceaccount.com
GOOGLE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nYOUR_ACTUAL_KEY\n-----END PRIVATE KEY-----
GA4_PROPERTY_ID=123456789
```

### Step 4: Install Dependencies

```bash
flutter pub get
```

### Step 5: Restart the App

```bash
flutter run
```

## 📁 File Structure

```
.
├── .env                    # 🔐 Your actual secrets (NOT in git)
├── .env.example            # 📝 Template (safe to commit)
├── .gitignore              # ✅ Includes .env
├── lib/
│   ├── config/
│   │   └── api_config.dart # 🔧 Reads from .env
│   └── main.dart           # 🚀 Loads .env at startup
└── pubspec.yaml            # 📦 Includes flutter_dotenv
```

## 🔒 Security Best Practices

### ✅ DO:
- Keep `.env` file local only
- Use `.env.example` as a template for team members
- Rotate keys regularly
- Use different keys for development/production
- Add `.env` to `.gitignore` (already done)

### ❌ DON'T:
- Commit `.env` to version control
- Share `.env` file via email/chat
- Hardcode secrets in source code
- Use production keys in development

## 🧪 Testing Your Setup

### Test 1: Check if .env is Loaded

Add this to your app temporarily:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

print('Supabase URL: ${dotenv.env['SUPABASE_URL']}');
print('Has Anon Key: ${dotenv.env['SUPABASE_ANON_KEY']?.isNotEmpty}');
```

### Test 2: Verify API Config

```dart
import 'package:your_app/config/api_config.dart';

print('API URL: ${ApiConfig.analyticsUrl}');
print('Has Auth: ${ApiConfig.supabaseAnonKey.isNotEmpty}');
```

## 🌍 Environment-Specific Configuration

### Development vs Production

Create multiple env files:

```bash
.env.development    # Local development
.env.staging        # Staging environment
.env.production     # Production environment
```

Load the appropriate one:

```dart
// In main.dart
await dotenv.load(fileName: ".env.development");
```

## 🔄 Updating Supabase Edge Function

Your Edge Function also needs these environment variables. Set them using Supabase CLI:

```bash
# Set secrets for your Edge Function
supabase secrets set GOOGLE_SERVICE_ACCOUNT_EMAIL="your-email@project.iam.gserviceaccount.com"
supabase secrets set GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
supabase secrets set GA4_PROPERTY_ID="123456789"

# List all secrets
supabase secrets list

# Deploy function with secrets
supabase functions deploy analytics
```

## 📊 What's Stored Where

### Flutter App (.env file):
- ✅ `SUPABASE_URL` - Public, but good to keep in .env
- ✅ `SUPABASE_ANON_KEY` - Public key, safe for client apps
- ❌ `GOOGLE_SERVICE_ACCOUNT_EMAIL` - Not used in Flutter app
- ❌ `GOOGLE_PRIVATE_KEY` - Not used in Flutter app
- ❌ `GA4_PROPERTY_ID` - Not used in Flutter app

### Supabase Edge Function (Supabase Secrets):
- ✅ `GOOGLE_SERVICE_ACCOUNT_EMAIL` - Used server-side
- ✅ `GOOGLE_PRIVATE_KEY` - Used server-side
- ✅ `GA4_PROPERTY_ID` - Used server-side

## 🐛 Troubleshooting

### Error: "Unable to load asset: .env"

**Solution:** Make sure `.env` is listed in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

Then run: `flutter pub get`

### Error: "dotenv.env is empty"

**Solution:** 
1. Check if `.env` file exists in project root
2. Verify it has content
3. Restart the app completely

### Error: "Null value returned from .env"

**Solution:**
1. Check variable name spelling in `.env`
2. Make sure there are no spaces around `=`
3. Use quotes for values with spaces

```bash
# ❌ Wrong
SUPABASE_URL = https://...

# ✅ Correct
SUPABASE_URL=https://...
```

## 📝 Example .env File

```bash
# Supabase Configuration
SUPABASE_URL=https://gdkwidkzbdwjtzgjezch.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Google Analytics (for Supabase Edge Function)
GOOGLE_SERVICE_ACCOUNT_EMAIL=analytics@my-project.iam.gserviceaccount.com
GOOGLE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0B...\n-----END PRIVATE KEY-----
GA4_PROPERTY_ID=123456789

# Optional: Database
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
DATABASE_URL=postgresql://postgres:password@db.project.supabase.co:5432/postgres
```

## ✅ Checklist

- [ ] `.env` file created in project root
- [ ] All required variables filled in
- [ ] `.env` is in `.gitignore`
- [ ] `flutter_dotenv` added to `pubspec.yaml`
- [ ] `.env` added to assets in `pubspec.yaml`
- [ ] `dotenv.load()` called in `main.dart`
- [ ] `flutter pub get` executed
- [ ] App restarted
- [ ] Supabase secrets set (for Edge Function)
- [ ] Edge Function deployed

## 🎉 You're Done!

Your app now securely loads all sensitive data from the `.env` file. The credentials are never hardcoded in your source code and won't be committed to version control.

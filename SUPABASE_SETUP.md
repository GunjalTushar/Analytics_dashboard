# 🚀 Supabase Setup Guide

## 📋 What You Need

From your Supabase project dashboard:

1. **Supabase URL** - Your project URL
   - Found in: Project Settings → API → Project URL
   - Format: `https://abcdefghijklmnop.supabase.co`

2. **Supabase Anon Key** - Your public/client key
   - Found in: Project Settings → API → Project API keys → `anon` `public`
   - This is safe to use in client apps

## 🔧 Flutter App Configuration

### Step 1: Add Your Credentials

Open `lib/config/api_config.dart` and replace:

```dart
static const String supabaseUrl = "https://YOUR_PROJECT.supabase.co";
static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";
```

### Step 2: Verify Edge Function Name

Make sure your Supabase Edge Function is named `analytics` (or update the config):

```dart
static const String analyticsFunction = "analytics"; // Change if different
```

## 📊 Expected Supabase Edge Function

Your Edge Function should be deployed at:
```
https://YOUR_PROJECT.supabase.co/functions/v1/analytics
```

And return data in this format:

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
      { "date": "2024-01-01", "users": 100 }
    ],
    "topCountries": [
      { "country": "USA", "users": 500 }
    ]
  }
}
```

## 🧪 Testing Your Setup

### 1. Test Edge Function First

Use curl or Postman to verify your Edge Function works:

```bash
curl -X GET \
  'https://YOUR_PROJECT.supabase.co/functions/v1/analytics' \
  -H 'apikey: YOUR_ANON_KEY' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'
```

### 2. Run Flutter App

```bash
flutter pub get
flutter run
```

## 🔐 Security Notes

✅ **Safe to use in Flutter:**
- Supabase URL (public)
- Supabase Anon Key (public)

🔒 **Keep on server (in Edge Function):**
- Google Service Account Email
- Google Service Account Private Key
- GA4 Property ID

## 📁 Typical Supabase Edge Function Structure

Your Edge Function should look like this:

```typescript
// supabase/functions/analytics/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { GoogleAuth } from "https://deno.land/x/google_auth@v1.0.0/mod.ts"

serve(async (req) => {
  try {
    // Authenticate with Google Analytics using service account
    const auth = new GoogleAuth({
      credentials: {
        client_email: Deno.env.get('GOOGLE_SERVICE_ACCOUNT_EMAIL'),
        private_key: Deno.env.get('GOOGLE_PRIVATE_KEY'),
      },
      scopes: ['https://www.googleapis.com/auth/analytics.readonly'],
    })

    // Fetch analytics data
    const response = await fetch(
      `https://analyticsdata.googleapis.com/v1beta/properties/${Deno.env.get('GA4_PROPERTY_ID')}:runReport`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${await auth.getAccessToken()}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          dateRanges: [{ startDate: '30daysAgo', endDate: 'today' }],
          dimensions: [{ name: 'date' }, { name: 'country' }],
          metrics: [
            { name: 'activeUsers' },
            { name: 'sessions' },
            { name: 'screenPageViews' },
            { name: 'engagementRate' }
          ],
        }),
      }
    )

    const data = await response.json()
    
    // Format and return data
    return new Response(
      JSON.stringify({
        success: true,
        data: formatAnalyticsData(data)
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
```

## 🐛 Troubleshooting

### "Failed to load analytics"

1. ✅ Check Supabase URL is correct
2. ✅ Check Anon Key is correct
3. ✅ Verify Edge Function is deployed
4. ✅ Test Edge Function with curl
5. ✅ Check Edge Function logs in Supabase dashboard

### CORS Errors

Edge Functions should automatically handle CORS, but if you get errors:

```typescript
// Add CORS headers to your Edge Function
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

return new Response(JSON.stringify(data), {
  headers: { ...corsHeaders, 'Content-Type': 'application/json' }
})
```

### Edge Function Not Found

Make sure it's deployed:

```bash
supabase functions deploy analytics
```

## ✅ Quick Checklist

- [ ] Supabase URL added to `lib/config/api_config.dart`
- [ ] Supabase Anon Key added to `lib/config/api_config.dart`
- [ ] Edge Function deployed and accessible
- [ ] Edge Function returns correct data format
- [ ] Tested with curl/Postman
- [ ] Run `flutter pub get`
- [ ] Run `flutter run`

## 🎯 Next Steps

Once configured:
1. The Flutter app will call your Supabase Edge Function
2. The Edge Function authenticates with Google Analytics (server-side)
3. Data flows back to your Flutter app
4. Same architecture as your React web app ✅

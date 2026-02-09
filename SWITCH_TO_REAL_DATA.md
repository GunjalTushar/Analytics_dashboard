# 🔄 Switch from Mock Data to Real Google Analytics Data

## Current Status

✅ Your app is working perfectly with mock data  
⚠️ Supabase Edge Function not deployed yet  
⚠️ App configured to use MockAnalyticsService  

## 🚀 Steps to Get Real Data

### Step 1: Deploy Supabase Edge Function

```bash
# 1. Install Supabase CLI (if not installed)
brew install supabase/tap/supabase

# 2. Login to Supabase
supabase login

# 3. Link your project
supabase link --project-ref gdkwidkzbdwjtzgjezch

# 4. Create the analytics function
supabase functions new analytics
```

This creates: `supabase/functions/analytics/index.ts`

### Step 2: Add Edge Function Code

Copy the code from `supabase_edge_function_example.ts` to `supabase/functions/analytics/index.ts`

Or use this simplified version for testing:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get credentials from environment
    const serviceAccountEmail = Deno.env.get('GOOGLE_SERVICE_ACCOUNT_EMAIL')
    const privateKey = Deno.env.get('GOOGLE_PRIVATE_KEY')
    const propertyId = Deno.env.get('GA4_PROPERTY_ID')

    if (!serviceAccountEmail || !privateKey || !propertyId) {
      throw new Error('Missing Google Analytics credentials')
    }

    // TODO: Add your Google Analytics API logic here
    // For now, return mock data to test deployment
    
    const mockData = {
      overview: {
        activeUsers: "2,456",
        sessions: "8,901",
        screenPageViews: "23,456",
        engagementRate: "72.3%"
      },
      dailyUsers: [
        { date: "2024-02-03", users: 150 },
        { date: "2024-02-04", users: 180 },
        { date: "2024-02-05", users: 200 },
        { date: "2024-02-06", users: 170 },
        { date: "2024-02-07", users: 220 },
        { date: "2024-02-08", users: 240 },
        { date: "2024-02-09", users: 260 }
      ],
      topCountries: [
        { country: "USA", users: 800 },
        { country: "India", users: 600 },
        { country: "UK", users: 400 },
        { country: "Canada", users: 300 },
        { country: "Germany", users: 200 }
      ]
    }

    return new Response(
      JSON.stringify({ success: true, data: mockData }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
```

### Step 3: Set Supabase Secrets

Your Google Analytics credentials need to be set as Supabase secrets:

```bash
# Set your actual Google credentials
supabase secrets set GOOGLE_SERVICE_ACCOUNT_EMAIL="your-actual-email@project.iam.gserviceaccount.com"

supabase secrets set GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
YOUR_ACTUAL_PRIVATE_KEY_HERE
-----END PRIVATE KEY-----"

supabase secrets set GA4_PROPERTY_ID="your-actual-property-id"
```

**Where to get these:**
- Service Account Email: [Google Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts)
- Private Key: Download JSON key from service account, copy the `private_key` field
- GA4 Property ID: Google Analytics → Admin → Property Settings

### Step 4: Deploy the Function

```bash
supabase functions deploy analytics
```

### Step 5: Test the Deployment

```bash
curl -X GET \
  'https://gdkwidkzbdwjtzgjezch.supabase.co/functions/v1/analytics' \
  -H 'apikey: YOUR_ANON_KEY' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'
```

Should return: `{"success": true, "data": {...}}`

### Step 6: Update Flutter App

Once the Edge Function is working, update the Flutter app:

**File:** `lib/screens/analytics_dashboard_screen.dart`

**Line ~42, change from:**
```dart
// 🧪 TEMPORARY: Using mock data while Edge Function is being set up
final result = await MockAnalyticsService.fetchAnalytics();
```

**To:**
```dart
// ✅ Using real Supabase Edge Function
final result = await AnalyticsService.fetchAnalytics();
```

### Step 7: Remove Mock Data Banner

In the same file, remove the orange banner (lines ~60-75):

**Delete this section:**
```dart
// 🧪 Mock Data Banner
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(12),
  color: Colors.orange[100],
  child: Row(
    children: [
      Icon(Icons.science, color: Colors.orange[900], size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          "Using mock data. Deploy Supabase Edge Function to see real analytics.",
          style: TextStyle(
            color: Colors.orange[900],
            fontSize: 12,
          ),
        ),
      ),
    ],
  ),
),
```

### Step 8: Hot Reload

In the terminal where Flutter is running, press `R` for hot restart.

## 🎉 Done!

Your app will now fetch real Google Analytics data!

## 🐛 Troubleshooting

### Edge Function Returns 404

**Problem:** Function not deployed  
**Solution:** Run `supabase functions deploy analytics`

### Edge Function Returns 500

**Problem:** Missing or invalid credentials  
**Solution:** 
1. Check secrets: `supabase secrets list`
2. Verify credentials are correct
3. Check function logs: `supabase functions logs analytics`

### App Still Shows Mock Data

**Problem:** Code not updated or hot reload didn't work  
**Solution:**
1. Verify you changed `MockAnalyticsService` to `AnalyticsService`
2. Do a full restart: Stop app and run `flutter run` again

### "Failed to load analytics" Error

**Problem:** Edge Function not returning correct format  
**Solution:**
1. Test Edge Function with curl
2. Check it returns `{"success": true, "data": {...}}`
3. Verify data structure matches `AnalyticsData` model

## 📋 Quick Checklist

- [ ] Supabase CLI installed
- [ ] Logged in to Supabase
- [ ] Project linked
- [ ] Edge Function created
- [ ] Edge Function code added
- [ ] Google credentials set as secrets
- [ ] Edge Function deployed
- [ ] Edge Function tested (returns 200)
- [ ] Flutter code updated (MockAnalyticsService → AnalyticsService)
- [ ] Mock banner removed
- [ ] App restarted
- [ ] Real data displaying

## 💡 Pro Tip

Keep the mock service for development! You can switch between them easily:

```dart
// Development mode
final result = await MockAnalyticsService.fetchAnalytics();

// Production mode
final result = await AnalyticsService.fetchAnalytics();
```

Or use an environment variable to switch automatically!

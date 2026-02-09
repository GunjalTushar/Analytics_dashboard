# 🚀 Deploy Supabase Edge Function

## Current Issue
Your Flutter app is configured correctly, but the Supabase Edge Function doesn't exist yet.

**Error:** `{"code":"NOT_FOUND","message":"Requested function was not found"}`

## ✅ Solution: Deploy the Edge Function

### Step 1: Install Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Or using npm
npm install -g supabase
```

### Step 2: Login to Supabase

```bash
supabase login
```

### Step 3: Link Your Project

```bash
supabase link --project-ref gdkwidkzbdwjtzgjezch
```

### Step 4: Create the Edge Function

```bash
supabase functions new analytics
```

This creates: `supabase/functions/analytics/index.ts`

### Step 5: Add the Function Code

Copy the code from `supabase_edge_function_example.ts` to `supabase/functions/analytics/index.ts`

Or use this simplified version:

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
    // TODO: Add your Google Analytics API logic here
    // For now, return mock data
    
    const mockData = {
      overview: {
        activeUsers: "1,234",
        sessions: "5,678",
        screenPageViews: "12,345",
        engagementRate: "67.8%"
      },
      dailyUsers: [
        { date: "2024-01-01", users: 100 },
        { date: "2024-01-02", users: 150 },
        { date: "2024-01-03", users: 120 },
        { date: "2024-01-04", users: 180 },
        { date: "2024-01-05", users: 200 },
        { date: "2024-01-06", users: 170 },
        { date: "2024-01-07", users: 190 }
      ],
      topCountries: [
        { country: "USA", users: 500 },
        { country: "UK", users: 300 },
        { country: "Canada", users: 200 },
        { country: "Germany", users: 150 },
        { country: "France", users: 100 }
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

### Step 6: Set Environment Variables

```bash
# Set your Google Analytics credentials
supabase secrets set GOOGLE_SERVICE_ACCOUNT_EMAIL="your-service-account@project.iam.gserviceaccount.com"
supabase secrets set GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
supabase secrets set GA4_PROPERTY_ID="123456789"
```

### Step 7: Deploy the Function

```bash
supabase functions deploy analytics
```

### Step 8: Test the Function

```bash
curl -X GET \
  'https://gdkwidkzbdwjtzgjezch.supabase.co/functions/v1/analytics' \
  -H 'apikey: YOUR_ANON_KEY' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'
```

### Step 9: Refresh Your Flutter App

Once deployed, tap the "Retry" button in your Flutter app or hot reload:
- Press `r` in the terminal for hot reload
- Or tap the refresh icon in the app

---

## 🎯 Quick Start with Mock Data

If you want to test the Flutter app immediately without Google Analytics:

1. Create the function with mock data (code above)
2. Deploy it: `supabase functions deploy analytics`
3. Refresh your Flutter app

This will show the dashboard with sample data while you set up the real Google Analytics integration.

---

## 📚 Resources

- [Supabase Edge Functions Docs](https://supabase.com/docs/guides/functions)
- [Google Analytics Data API](https://developers.google.com/analytics/devguides/reporting/data/v1)
- Your example code: `supabase_edge_function_example.ts`

#!/bin/bash

# 🧪 Test Supabase Edge Function Connection
# 
# This script helps you verify your Supabase Edge Function is working
# before testing with the Flutter app

echo "🧪 Testing Supabase Edge Function Connection"
echo "=============================================="
echo ""

# Check if required variables are set
if [ -z "$SUPABASE_URL" ]; then
    echo "❌ Error: SUPABASE_URL not set"
    echo ""
    echo "Usage:"
    echo "  export SUPABASE_URL='https://your-project.supabase.co'"
    echo "  export SUPABASE_ANON_KEY='your-anon-key'"
    echo "  ./test_supabase_connection.sh"
    exit 1
fi

if [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Error: SUPABASE_ANON_KEY not set"
    echo ""
    echo "Usage:"
    echo "  export SUPABASE_URL='https://your-project.supabase.co'"
    echo "  export SUPABASE_ANON_KEY='your-anon-key'"
    echo "  ./test_supabase_connection.sh"
    exit 1
fi

echo "📡 Testing connection to:"
echo "   $SUPABASE_URL/functions/v1/analytics"
echo ""

# Make the request
response=$(curl -s -w "\n%{http_code}" \
  -X GET \
  "$SUPABASE_URL/functions/v1/analytics" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json")

# Extract status code and body
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

echo "📊 Response Status: $http_code"
echo ""

if [ "$http_code" = "200" ]; then
    echo "✅ Success! Edge Function is working"
    echo ""
    echo "📄 Response:"
    echo "$body" | python3 -m json.tool 2>/dev/null || echo "$body"
    echo ""
    echo "🎉 Your Flutter app should work now!"
    echo ""
    echo "Next steps:"
    echo "1. Copy your SUPABASE_URL to lib/config/api_config.dart"
    echo "2. Copy your SUPABASE_ANON_KEY to lib/config/api_config.dart"
    echo "3. Run: flutter pub get"
    echo "4. Run: flutter run"
else
    echo "❌ Error: Request failed"
    echo ""
    echo "📄 Response:"
    echo "$body"
    echo ""
    echo "🔍 Troubleshooting:"
    echo "1. Check if Edge Function is deployed: supabase functions list"
    echo "2. Check Edge Function logs: supabase functions logs analytics"
    echo "3. Verify environment variables are set in Supabase dashboard"
    echo "4. Make sure function name matches (default: 'analytics')"
fi

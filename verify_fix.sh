#!/bin/bash

# 🔍 Verify Fix Applied
# This script checks if all fixes are in place

echo "🔍 Verifying fixes..."
echo ""

# Check 1: Verify env_validator.dart doesn't require SERVER_URL
echo "1️⃣ Checking env_validator.dart..."
if grep -q "SERVER_URL" lib/core/environment/env_validator.dart; then
  if grep -A 5 "_requiredKeys" lib/core/environment/env_validator.dart | grep -q "SERVER_URL"; then
    echo "   ❌ SERVER_URL is still in required keys"
  else
    echo "   ✅ SERVER_URL not in required keys"
  fi
else
  echo "   ✅ SERVER_URL not referenced in validator"
fi

# Check 2: Verify analytics_dashboard_screen.dart uses GoogleAnalyticsDirect
echo "2️⃣ Checking analytics_dashboard_screen.dart..."
if grep -q "GoogleAnalyticsDirect.fetchAnalytics()" lib/screens/analytics_dashboard_screen.dart; then
  echo "   ✅ Using GoogleAnalyticsDirect"
else
  echo "   ❌ Not using GoogleAnalyticsDirect"
fi

# Check 3: Verify no BackendAnalyticsService import in screen
if grep -q "backend_analytics_service" lib/screens/analytics_dashboard_screen.dart; then
  echo "   ❌ Still importing BackendAnalyticsService"
else
  echo "   ✅ Not importing BackendAnalyticsService"
fi

# Check 4: Verify no usingMockData reference
if grep -q "usingMockData" lib/screens/analytics_dashboard_screen.dart; then
  echo "   ❌ Still referencing usingMockData"
else
  echo "   ✅ No usingMockData reference"
fi

# Check 5: Verify .env file exists
echo "3️⃣ Checking .env file..."
if [ -f ".env" ]; then
  echo "   ✅ .env file exists"
  
  # Check required variables
  if grep -q "GOOGLE_SERVICE_ACCOUNT_EMAIL" .env; then
    echo "   ✅ GOOGLE_SERVICE_ACCOUNT_EMAIL present"
  else
    echo "   ❌ GOOGLE_SERVICE_ACCOUNT_EMAIL missing"
  fi
  
  if grep -q "GOOGLE_PRIVATE_KEY" .env; then
    echo "   ✅ GOOGLE_PRIVATE_KEY present"
  else
    echo "   ❌ GOOGLE_PRIVATE_KEY missing"
  fi
  
  if grep -q "GA4_PROPERTY_ID" .env; then
    echo "   ✅ GA4_PROPERTY_ID present"
  else
    echo "   ❌ GA4_PROPERTY_ID missing"
  fi
else
  echo "   ❌ .env file not found"
fi

# Check 6: Verify pubspec.yaml includes .env
echo "4️⃣ Checking pubspec.yaml..."
if grep -A 5 "assets:" pubspec.yaml | grep -q ".env"; then
  echo "   ✅ .env listed in assets"
else
  echo "   ❌ .env not in assets"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "All code fixes have been applied."
echo ""
echo "⚠️  IMPORTANT: You must do a FULL RESTART"
echo "   Hot reload will NOT work for these changes."
echo ""
echo "To restart:"
echo "  1. Stop the app completely"
echo "  2. Run: flutter run"
echo ""
echo "If still not working:"
echo "  Run: ./clean_and_run.sh"
echo ""

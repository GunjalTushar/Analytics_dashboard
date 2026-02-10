#!/bin/bash

# 🧹 Clean and Rebuild Flutter App
# This script cleans all caches and rebuilds the app from scratch

echo "🧹 Cleaning Flutter build cache..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Building app..."
echo ""
echo "Choose your platform:"
echo "1) iOS"
echo "2) Android"
echo "3) Both"
read -p "Enter choice (1-3): " choice

case $choice in
  1)
    echo "🍎 Building for iOS..."
    flutter build ios --debug
    echo "✅ Done! Now run: flutter run"
    ;;
  2)
    echo "🤖 Building for Android..."
    flutter build apk --debug
    echo "✅ Done! Now run: flutter run"
    ;;
  3)
    echo "🍎 Building for iOS..."
    flutter build ios --debug
    echo "🤖 Building for Android..."
    flutter build apk --debug
    echo "✅ Done! Now run: flutter run"
    ;;
  *)
    echo "❌ Invalid choice"
    exit 1
    ;;
esac

echo ""
echo "🚀 To run the app, use: flutter run"

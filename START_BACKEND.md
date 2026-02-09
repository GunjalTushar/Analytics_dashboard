# 🚀 Start the Backend Server

## Why You Need This

Flutter **cannot** directly call Google Analytics API because:
- Requires RSA-SHA256 signing (Flutter can't do this securely)
- Private keys can't be stored in mobile apps (security risk)

**Solution:** Run a simple Node.js backend locally that handles Google authentication.

## Quick Start

### 1. Install Node.js dependencies

```bash
cd backend
npm install
```

### 2. Start the backend server

```bash
npm start
```

You should see:
```
✅ Backend server running on http://localhost:3000
📊 Analytics endpoint: http://localhost:3000/api/analytics
```

### 3. Run your Flutter app

In a new terminal:
```bash
flutter run
```

## ✅ Done!

Your Flutter app will now fetch **real Google Analytics data** from the backend server!

## 🔍 How It Works

```
Flutter App → http://localhost:3000/api/analytics → Node.js Backend → Google Analytics API
```

The backend:
- Reads your Google credentials from .env
- Authenticates with Google (RSA signing)
- Fetches analytics data
- Returns formatted data to Flutter

## 🐛 Troubleshooting

### "Connection refused"
- Make sure backend is running: `cd backend && npm start`
- Check it's on port 3000

### "Authentication error"
- Verify .env has correct Google credentials
- Check service account has Analytics permissions

### Test the backend directly

```bash
curl http://localhost:3000/api/analytics
```

Should return JSON with analytics data.

# ⚠️ SECURITY WARNING: Service Account Credentials

## 🚨 DO NOT Store Service Account Credentials in Flutter App

Your Google service account credentials (email + private key) should **NEVER** be embedded directly in a Flutter app because:

### Security Risks:
1. **Exposed in APK/IPA** - Anyone can decompile your app and extract the credentials
2. **Version Control** - Credentials may be committed to Git history
3. **Unlimited Access** - Stolen credentials give full access to your Google Analytics
4. **Can't Revoke** - Once distributed, you can't remove credentials from user devices

## ✅ Correct Architecture (What You Should Use)

```
Flutter App → Your Backend API → Google Analytics API
                    ↑
            (Credentials stored here)
```

### Your Backend Should:
1. Store service account credentials securely (environment variables)
2. Authenticate with Google Analytics API
3. Expose a `/api/analytics` endpoint
4. Return formatted data to your Flutter app

### Example Backend (Node.js):

```javascript
// server.js
const { google } = require('googleapis');

const analytics = google.analyticsdata('v1beta');

const auth = new google.auth.GoogleAuth({
  credentials: {
    client_email: process.env.GOOGLE_SERVICE_ACCOUNT_EMAIL,
    private_key: process.env.GOOGLE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  },
  scopes: ['https://www.googleapis.com/auth/analytics.readonly'],
});

app.get('/api/analytics', async (req, res) => {
  const authClient = await auth.getClient();
  
  const response = await analytics.properties.runReport({
    auth: authClient,
    property: `properties/${process.env.GA4_PROPERTY_ID}`,
    requestBody: {
      dateRanges: [{ startDate: '30daysAgo', endDate: 'today' }],
      dimensions: [{ name: 'date' }, { name: 'country' }],
      metrics: [
        { name: 'activeUsers' },
        { name: 'sessions' },
        { name: 'screenPageViews' },
        { name: 'engagementRate' }
      ],
    },
  });
  
  res.json({ success: true, data: formatData(response.data) });
});
```

## 🔧 For Local Testing Only

If you need to test direct access (development only):

1. Add to `pubspec.yaml`:
   ```yaml
   dependencies:
     googleapis_auth: ^1.4.1
   ```

2. Use `lib/services/google_analytics_direct.dart` (already created)

3. **NEVER deploy this to production**

4. Add to `.gitignore`:
   ```
   lib/services/google_analytics_direct.dart
   ```

## 📝 Recommended Setup

1. Keep your service account credentials on your backend server
2. Use environment variables (`.env` file)
3. Your Flutter app only needs the backend URL
4. Update `lib/config/api_config.dart` with your backend URL

```dart
static const String baseUrl = "https://yourdomain.com";
// or for local testing:
// static const String baseUrl = "http://localhost:3000";
```

## 🎯 Summary

✅ **DO**: Use backend proxy (your current React setup)  
❌ **DON'T**: Put service account credentials in Flutter app  
✅ **DO**: Store credentials in environment variables on server  
❌ **DON'T**: Commit credentials to Git  

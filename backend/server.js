// Simple Node.js backend to fetch Google Analytics data
// Run with: node server.js

const express = require('express');
const { google } = require('googleapis');
require('dotenv').config({ path: '../.env' });

const app = express();
const PORT = 3000;

// Enable CORS
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  next();
});

// Google Analytics endpoint
app.get('/api/analytics', async (req, res) => {
  try {
    // Get credentials from .env
    const serviceAccountEmail = process.env.GOOGLE_SERVICE_ACCOUNT_EMAIL;
    const privateKey = process.env.GOOGLE_PRIVATE_KEY.replace(/\\n/g, '\n').replace(/"/g, '');
    const propertyId = process.env.GA4_PROPERTY_ID;

    console.log('Service Account:', serviceAccountEmail);
    console.log('Property ID:', propertyId);

    // Create auth client
    const auth = new google.auth.GoogleAuth({
      credentials: {
        client_email: serviceAccountEmail,
        private_key: privateKey,
      },
      scopes: ['https://www.googleapis.com/auth/analytics.readonly'],
    });

    const authClient = await auth.getClient();
    const analyticsData = google.analyticsdata('v1beta');

    // Fetch data from Google Analytics
    const response = await analyticsData.properties.runReport({
      auth: authClient,
      property: `properties/${propertyId}`,
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

    // Format the data
    const formattedData = formatAnalyticsData(response.data);
    
    res.json({ success: true, data: formattedData });
  } catch (error) {
    console.error('Error:', error.message);
    res.status(500).json({ success: false, error: error.message });
  }
});

function formatAnalyticsData(data) {
  const rows = data.rows || [];
  
  let totalUsers = 0;
  let totalSessions = 0;
  let totalPageViews = 0;
  let totalEngagement = 0;
  
  const dailyUsersMap = {};
  const countryUsersMap = {};
  
  rows.forEach(row => {
    const date = row.dimensionValues[0].value;
    const country = row.dimensionValues[1].value;
    const users = parseInt(row.metricValues[0].value || '0');
    const sessions = parseInt(row.metricValues[1].value || '0');
    const pageViews = parseInt(row.metricValues[2].value || '0');
    const engagement = parseFloat(row.metricValues[3].value || '0');
    
    totalUsers += users;
    totalSessions += sessions;
    totalPageViews += pageViews;
    totalEngagement += engagement;
    
    dailyUsersMap[date] = (dailyUsersMap[date] || 0) + users;
    countryUsersMap[country] = (countryUsersMap[country] || 0) + users;
  });
  
  const dailyUsers = Object.entries(dailyUsersMap)
    .map(([date, users]) => ({ date, users }))
    .sort((a, b) => a.date.localeCompare(b.date));
  
  const topCountries = Object.entries(countryUsersMap)
    .map(([country, users]) => ({ country, users }))
    .sort((a, b) => b.users - a.users)
    .slice(0, 10);
  
  const avgEngagement = rows.length > 0 ? totalEngagement / rows.length : 0;
  
  return {
    overview: {
      activeUsers: totalUsers.toString(),
      sessions: totalSessions.toString(),
      screenPageViews: totalPageViews.toString(),
      engagementRate: `${avgEngagement.toFixed(1)}%`,
    },
    dailyUsers,
    topCountries,
  };
}

app.listen(PORT, () => {
  console.log(`✅ Backend server running on http://localhost:${PORT}`);
  console.log(`📊 Analytics endpoint: http://localhost:${PORT}/api/analytics`);
});

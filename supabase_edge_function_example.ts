// 📊 Supabase Edge Function Example
// 
// This is a reference example of what your Supabase Edge Function should look like
// Deploy this to: supabase/functions/analytics/index.ts
//
// Deploy command: supabase functions deploy analytics

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// CORS headers for client requests
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get service account credentials from environment variables
    const serviceAccountEmail = Deno.env.get('GOOGLE_SERVICE_ACCOUNT_EMAIL')
    const privateKey = Deno.env.get('GOOGLE_PRIVATE_KEY')?.replace(/\\n/g, '\n')
    const propertyId = Deno.env.get('GA4_PROPERTY_ID')

    if (!serviceAccountEmail || !privateKey || !propertyId) {
      throw new Error('Missing required environment variables')
    }

    // Create JWT for Google OAuth
    const jwt = await createJWT(serviceAccountEmail, privateKey)
    
    // Exchange JWT for access token
    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt,
      }),
    })

    const { access_token } = await tokenResponse.json()

    // Fetch analytics data from Google Analytics Data API
    const analyticsResponse = await fetch(
      `https://analyticsdata.googleapis.com/v1beta/properties/${propertyId}:runReport`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${access_token}`,
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
          orderBys: [{ dimension: { dimensionName: 'date' } }],
          limit: 10000,
        }),
      }
    )

    const analyticsData = await analyticsResponse.json()

    // Format the response to match Flutter app expectations
    const formattedData = formatAnalyticsData(analyticsData)

    return new Response(
      JSON.stringify({
        success: true,
        data: formattedData
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Analytics error:', error)
    
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || 'Failed to fetch analytics'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

// Helper function to create JWT for Google OAuth
async function createJWT(email: string, privateKey: string): Promise<string> {
  const header = {
    alg: 'RS256',
    typ: 'JWT',
  }

  const now = Math.floor(Date.now() / 1000)
  const claim = {
    iss: email,
    scope: 'https://www.googleapis.com/auth/analytics.readonly',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  }

  const encodedHeader = base64UrlEncode(JSON.stringify(header))
  const encodedClaim = base64UrlEncode(JSON.stringify(claim))
  const signatureInput = `${encodedHeader}.${encodedClaim}`

  // Import private key
  const keyData = privateKey
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s/g, '')

  const binaryKey = Uint8Array.from(atob(keyData), c => c.charCodeAt(0))

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryKey,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )

  // Sign the JWT
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(signatureInput)
  )

  const encodedSignature = base64UrlEncode(signature)
  return `${signatureInput}.${encodedSignature}`
}

function base64UrlEncode(data: string | ArrayBuffer): string {
  const bytes = typeof data === 'string' 
    ? new TextEncoder().encode(data)
    : new Uint8Array(data)
  
  let binary = ''
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i])
  }
  
  return btoa(binary)
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '')
}

// Format Google Analytics response to match Flutter app expectations
function formatAnalyticsData(data: any) {
  const rows = data.rows || []

  // Calculate overview metrics
  let totalUsers = 0
  let totalSessions = 0
  let totalPageViews = 0
  let totalEngagement = 0

  const dailyUsersMap = new Map<string, number>()
  const countryUsersMap = new Map<string, number>()

  rows.forEach((row: any) => {
    const date = row.dimensionValues[0].value
    const country = row.dimensionValues[1].value
    const users = parseInt(row.metricValues[0].value || '0')
    const sessions = parseInt(row.metricValues[1].value || '0')
    const pageViews = parseInt(row.metricValues[2].value || '0')
    const engagement = parseFloat(row.metricValues[3].value || '0')

    totalUsers += users
    totalSessions += sessions
    totalPageViews += pageViews
    totalEngagement += engagement

    // Aggregate by date
    dailyUsersMap.set(date, (dailyUsersMap.get(date) || 0) + users)

    // Aggregate by country
    countryUsersMap.set(country, (countryUsersMap.get(country) || 0) + users)
  })

  // Format daily users
  const dailyUsers = Array.from(dailyUsersMap.entries())
    .map(([date, users]) => ({ date, users }))
    .sort((a, b) => a.date.localeCompare(b.date))

  // Format top countries
  const topCountries = Array.from(countryUsersMap.entries())
    .map(([country, users]) => ({ country, users }))
    .sort((a, b) => b.users - a.users)
    .slice(0, 10)

  const avgEngagement = rows.length > 0 ? totalEngagement / rows.length : 0

  return {
    overview: {
      activeUsers: totalUsers.toLocaleString(),
      sessions: totalSessions.toLocaleString(),
      screenPageViews: totalPageViews.toLocaleString(),
      engagementRate: `${avgEngagement.toFixed(1)}%`,
    },
    dailyUsers,
    topCountries,
  }
}

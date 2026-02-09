#!/usr/bin/env python3
"""Simple Python backend to fetch Google Analytics data"""

from flask import Flask, jsonify
from google.oauth2 import service_account
from googleapiclient.discovery import build
import os
from dotenv import load_dotenv

# Load .env from parent directory
import sys
from pathlib import Path

# Get the parent directory (project root)
parent_dir = Path(__file__).parent.parent
env_path = parent_dir / '.env'

print(f'Loading .env from: {env_path}')
load_dotenv(env_path)

app = Flask(__name__)

# Enable CORS
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
    return response

@app.route('/api/analytics')
def get_analytics():
    try:
        # Get credentials from .env
        service_account_email = os.getenv('GOOGLE_SERVICE_ACCOUNT_EMAIL')
        private_key_raw = os.getenv('GOOGLE_PRIVATE_KEY')
        property_id = os.getenv('GA4_PROPERTY_ID')

        print(f'Service Account: {service_account_email}')
        print(f'Property ID: {property_id}')
        
        # Clean up the private key - remove quotes and fix newlines
        private_key = private_key_raw.strip()
        if private_key.startswith('"') and private_key.endswith('"'):
            private_key = private_key[1:-1]
        private_key = private_key.replace('\\n', '\n')
        
        print(f'Private key starts with: {private_key[:30]}...')
        print(f'Private key ends with: ...{private_key[-30:]}')

        # Create credentials
        credentials = service_account.Credentials.from_service_account_info(
            {
                'type': 'service_account',
                'client_email': service_account_email,
                'private_key': private_key,
                'token_uri': 'https://oauth2.googleapis.com/token',
            },
            scopes=['https://www.googleapis.com/auth/analytics.readonly']
        )

        # Build the service
        analytics = build('analyticsdata', 'v1beta', credentials=credentials)

        # Fetch overview data (totals without dimensions)
        overview_response = analytics.properties().runReport(
            property=f'properties/{property_id}',
            body={
                'dateRanges': [{'startDate': '30daysAgo', 'endDate': 'today'}],
                'metrics': [
                    {'name': 'activeUsers'},
                    {'name': 'sessions'},
                    {'name': 'screenPageViews'},
                    {'name': 'engagementRate'}
                ],
            }
        ).execute()

        # Fetch daily users data
        daily_response = analytics.properties().runReport(
            property=f'properties/{property_id}',
            body={
                'dateRanges': [{'startDate': '30daysAgo', 'endDate': 'today'}],
                'dimensions': [{'name': 'date'}],
                'metrics': [{'name': 'activeUsers'}],
            }
        ).execute()
        
        # Fetch country data
        country_response = analytics.properties().runReport(
            property=f'properties/{property_id}',
            body={
                'dateRanges': [{'startDate': '30daysAgo', 'endDate': 'today'}],
                'dimensions': [{'name': 'country'}],
                'metrics': [{'name': 'activeUsers'}],
            }
        ).execute()

        # Format the data
        formatted_data = format_analytics_data(overview_response, daily_response, country_response)
        
        return jsonify({'success': True, 'data': formatted_data})
    
    except Exception as e:
        print(f'Error: {str(e)}')
        import traceback
        traceback.print_exc()
        return jsonify({'success': False, 'error': str(e)}), 500

def format_analytics_data(overview_data, daily_data, country_data):
    # Get overview totals (correct values without double-counting)
    overview_rows = overview_data.get('rows', [])
    if overview_rows:
        row = overview_rows[0]
        total_users = int(row['metricValues'][0].get('value', 0))
        total_sessions = int(row['metricValues'][1].get('value', 0))
        total_page_views = int(row['metricValues'][2].get('value', 0))
        # Engagement rate is returned as decimal (0.663), multiply by 100 for percentage
        avg_engagement = float(row['metricValues'][3].get('value', 0)) * 100
    else:
        total_users = 0
        total_sessions = 0
        total_page_views = 0
        avg_engagement = 0
    
    # Get daily users
    daily_users = []
    for row in daily_data.get('rows', []):
        date = row['dimensionValues'][0]['value']
        users = int(row['metricValues'][0].get('value', 0))
        daily_users.append({'date': date, 'users': users})
    
    daily_users.sort(key=lambda x: x['date'])
    
    # Get top countries
    top_countries = []
    for row in country_data.get('rows', []):
        country = row['dimensionValues'][0]['value']
        users = int(row['metricValues'][0].get('value', 0))
        top_countries.append({'country': country, 'users': users})
    
    top_countries.sort(key=lambda x: x['users'], reverse=True)
    top_countries = top_countries[:10]
    
    return {
        'overview': {
            'activeUsers': str(total_users),
            'sessions': str(total_sessions),
            'screenPageViews': str(total_page_views),
            'engagementRate': f'{avg_engagement:.1f}%',
        },
        'dailyUsers': daily_users,
        'topCountries': top_countries,
    }

if __name__ == '__main__':
    print('✅ Backend server running on http://localhost:3000')
    print('📊 Analytics endpoint: http://localhost:3000/api/analytics')
    app.run(port=3000, debug=True)

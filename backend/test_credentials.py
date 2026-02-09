#!/usr/bin/env python3
"""Test Google Analytics credentials"""

import os
from dotenv import load_dotenv
from pathlib import Path
from google.oauth2 import service_account
from googleapiclient.discovery import build

# Load .env
parent_dir = Path(__file__).parent.parent
env_path = parent_dir / '.env'
load_dotenv(env_path)

def test_credentials():
    print("=" * 60)
    print("TESTING GOOGLE ANALYTICS CREDENTIALS")
    print("=" * 60)
    
    # Get credentials
    service_account_email = os.getenv('GOOGLE_SERVICE_ACCOUNT_EMAIL')
    private_key_raw = os.getenv('GOOGLE_PRIVATE_KEY')
    property_id = os.getenv('GA4_PROPERTY_ID')
    
    print(f"\n✓ Service Account Email: {service_account_email}")
    print(f"✓ GA4 Property ID: {property_id}")
    print(f"✓ Private Key Length: {len(private_key_raw)} characters")
    
    # Clean up private key
    private_key = private_key_raw.strip()
    if private_key.startswith('"') and private_key.endswith('"'):
        private_key = private_key[1:-1]
    private_key = private_key.replace('\\n', '\n')
    
    print(f"\n✓ Private Key Format:")
    print(f"  - Starts with: {private_key[:30]}")
    print(f"  - Ends with: {private_key[-30:]}")
    
    try:
        # Create credentials
        print("\n⏳ Creating credentials...")
        credentials = service_account.Credentials.from_service_account_info(
            {
                'type': 'service_account',
                'client_email': service_account_email,
                'private_key': private_key,
                'token_uri': 'https://oauth2.googleapis.com/token',
            },
            scopes=['https://www.googleapis.com/auth/analytics.readonly']
        )
        print("✓ Credentials created successfully")
        
        # Build the service
        print("\n⏳ Building Analytics Data API service...")
        analytics = build('analyticsdata', 'v1beta', credentials=credentials)
        print("✓ Service built successfully")
        
        # Try to fetch data
        print(f"\n⏳ Fetching data from property {property_id}...")
        response = analytics.properties().runReport(
            property=f'properties/{property_id}',
            body={
                'dateRanges': [{'startDate': '7daysAgo', 'endDate': 'today'}],
                'dimensions': [{'name': 'date'}],
                'metrics': [{'name': 'activeUsers'}],
            }
        ).execute()
        
        print("✓ Data fetched successfully!")
        print(f"\n📊 Response contains {len(response.get('rows', []))} rows")
        
        if response.get('rows'):
            print("\nSample data:")
            for row in response['rows'][:3]:
                date = row['dimensionValues'][0]['value']
                users = row['metricValues'][0]['value']
                print(f"  {date}: {users} users")
        
        print("\n" + "=" * 60)
        print("✅ ALL TESTS PASSED!")
        print("=" * 60)
        print("\nYour credentials are working correctly.")
        print("The backend server should now work properly.")
        
    except Exception as e:
        print(f"\n❌ ERROR: {str(e)}")
        print("\n" + "=" * 60)
        print("TROUBLESHOOTING STEPS:")
        print("=" * 60)
        print("\n1. Verify the service account has access to GA4:")
        print(f"   - Go to: https://analytics.google.com/")
        print(f"   - Select your property (ID: {property_id})")
        print(f"   - Go to: Admin > Property Access Management")
        print(f"   - Add user: {service_account_email}")
        print(f"   - Role: Viewer or higher")
        print("\n2. Verify the private key is correct:")
        print("   - Download a new JSON key from Google Cloud Console")
        print("   - Update the GOOGLE_PRIVATE_KEY in .env")
        print("\n3. Verify the property ID is correct:")
        print("   - Check in Google Analytics Admin settings")
        
        import traceback
        print("\n" + "=" * 60)
        print("FULL ERROR TRACE:")
        print("=" * 60)
        traceback.print_exc()

if __name__ == '__main__':
    test_credentials()
